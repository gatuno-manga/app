import 'dart:async';
import 'dart:io';

import 'package:rxdart/rxdart.dart';

import '../../../../core/connectivity/connectivity_service.dart';
import '../../../../core/covers/cover_store.dart';
import '../../../../core/logging/logger.dart';
import '../../../../core/network/exceptions.dart';
import '../../../books/domain/entities/book.dart';
import '../../../books/domain/entities/chapter_page_options.dart';
import '../../../books/domain/repositories/books_repository.dart';
import '../../../books/domain/value_objects/book_id.dart';
import '../../../books/domain/value_objects/chapter_id.dart';
import '../../../reading/data/models/reading_chapter_model.dart';
import '../../../reading/domain/entities/reading_enums.dart';
import '../../domain/entities/book_download.dart';
import '../../domain/entities/chapter_download.dart';
import '../../domain/entities/download_network.dart';
import '../../domain/entities/download_scope.dart';
import '../../domain/entities/download_state.dart';
import '../../domain/entities/download_totals.dart';
import '../../domain/repositories/download_network_policy.dart';
import '../../domain/repositories/download_service.dart';
import '../../domain/use_cases/chapter_file_plan.dart';
import '../../domain/use_cases/download_book_type.dart';
import '../../domain/use_cases/download_state_machine.dart';
import '../../exceptions/download_exceptions.dart';
import '../data_sources/download_records.dart';
import '../data_sources/download_remote_data_source.dart';
import '../data_sources/download_storage.dart';
import '../data_sources/transfer_queue.dart';
import '../database/downloads_database.dart';

/// [DownloadService] that plans chapters in Dart and hands their files to
/// the native [TransferQueue].
///
/// Planning a chapter fetches its manifest (`GET /chapters/:id`, through
/// `DioClient`), stores it, and records one row per file; that needs the app
/// running. Every file then goes straight to the native queue, which keeps
/// downloading with the app closed; the outcome is applied when events
/// arrive or, on the next [start], from what is on disk. What the native
/// side guarantees with the app closed (retries, resumes) is up to the
/// [TransferQueue] implementation.
///
/// Every change to the records runs through [_serial], so a native event, a
/// user command and a finished plan never interleave.
class DownloadManager implements DownloadService {
  /// Owner of the cover pins this manager holds in [CoverStore].
  static const String coverPinOwner = 'download';

  /// How long [dispose] waits for the serial work in flight.
  static const Duration disposeGrace = Duration(seconds: 2);

  /// Manifests fetched at once.
  static const int planConcurrency = 4;

  /// Tries of a manifest that keeps timing out or answering busy (429,
  /// 502-504) while the server is reachable.
  static const int maxTransientAttempts = 3;

  final DownloadRecords _records;
  final DownloadStorage _storage;
  final TransferQueue _transfers;
  final DownloadRemoteDataSource _remote;
  final BooksRepository _books;
  final CoverStore _covers;
  final DownloadNetworkPolicy _policy;
  final ConnectivityService _connectivity;
  final Stream<bool> _unmetered;
  final DateTime Function() _now;
  final Duration _planRetryDelay;

  static const String _logTag = 'DownloadManager';

  /// Distinguishes this app session's native task ids from earlier ones.
  late final String _session = _now().microsecondsSinceEpoch.toRadixString(36);
  int _attempt = 0;

  Future<void> _tail = Future<void>.value();
  Future<void>? _started;
  final List<StreamSubscription<Object?>> _subscriptions = [];
  final BehaviorSubject<Map<BookType, DownloadNetwork>> _rules =
      BehaviorSubject.seeded(const {});

  /// Bumped by deletes, per book and for everything, so an enqueue issued
  /// before a delete does not come back after it (its book lookup or chapter
  /// paging can take a while).
  final Map<String, int> _deletedBooks = {};
  int _deletedAll = 0;

  /// Transient manifest failures per chapter in this session; a chapter
  /// fails after [maxTransientAttempts] instead of blocking the queue head.
  final Map<String, int> _transientFailures = {};
  bool _planning = false;
  bool _disposed = false;
  bool _planAgain = false;
  Timer? _planRetry;
  Timer? _resyncRetry;

  DownloadManager({
    required DownloadRecords records,
    required DownloadStorage storage,
    required TransferQueue transfers,
    required DownloadRemoteDataSource remote,
    required BooksRepository books,
    required CoverStore covers,
    required DownloadNetworkPolicy policy,
    required ConnectivityService connectivity,
    required Stream<bool> unmetered,
    DateTime Function()? now,
    Duration planRetryDelay = const Duration(seconds: 30),
  }) : _records = records,
       _storage = storage,
       _transfers = transfers,
       _remote = remote,
       _books = books,
       _covers = covers,
       _policy = policy,
       _connectivity = connectivity,
       _unmetered = unmetered,
       _now = now ?? DateTime.now,
       _planRetryDelay = planRetryDelay;

  /// Configures the native queue, applies what happened while the app was
  /// closed, then plans chapters left unplanned. Queued as the first serial
  /// operation, synchronously, so commands issued meanwhile run after it.
  Future<void> start() {
    return _started ??= () {
      _subscriptions
        ..add(
          _transfers.events.listen(
            (event) => _guard(
              'Transfer event',
              () => _serial(() => _onTransfer(event)),
            ),
          ),
        )
        ..add(
          _policy.changes.listen(
            (_) => _guard('Network rule change', _onRulesChanged),
          ),
        )
        ..add(
          _connectivity.onReconnected.listen((_) {
            // Back online: no reason to wait out the backoff.
            _planRetry?.cancel();
            _planRetry = null;
            unawaited(_plan());
          }),
        );
      return _serial(() async {
        var userCancels = const <String>{};
        try {
          userCancels = await _transfers.start();
        } catch (e, stackTrace) {
          // Planning and the records still work; files wait for a restart.
          AppLogger.e('Native downloader unavailable', e, stackTrace, _logTag);
        }
        final rules = await _loadRules();
        if (!_rules.isClosed) _rules.add(rules);
        // Before reconciling, which would queue those files again.
        await _onUserCancel(userCancels);
        await _reconcile();
      }).whenComplete(() => unawaited(_plan()));
    }();
  }

  Future<void> dispose() async {
    _disposed = true;
    _planRetry?.cancel();
    _resyncRetry?.cancel();
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    // Let the serial work in flight finish before the owner closes the
    // database and storage under it. Bounded: a native call that never
    // answers (no plugin) must not hold the teardown; plans that land later
    // are dropped by [_disposed].
    await _tail.timeout(disposeGrace, onTimeout: () {});
    await _rules.close();
  }

  // ---------------------------------------------------------------------------
  // Commands

  @override
  Future<void> enqueueChapters(BookId bookId, List<ChapterId> chapterIds) =>
      _enqueue(bookId, chapterIds, _deletionMark(bookId));

  ({int book, int all}) _deletionMark(BookId bookId) =>
      (book: _deletedBooks[bookId.value] ?? 0, all: _deletedAll);

  Future<void> _enqueue(
    BookId bookId,
    List<ChapterId> chapterIds,
    ({int book, int all}) mark,
  ) async {
    if (chapterIds.isEmpty) return;
    final book = await _bookOrNull(bookId);
    await _serial(() async {
      if (_deletionMark(bookId) != mark) return;
      final now = _now();
      // Only database writes in the transaction: requeueing talks to the
      // native queue and the file system, which a rollback cannot undo.
      final existing = await _records.transaction(() async {
        await _records.upsertBook(bookId.value, book?.type.asBookType, now);
        final existing = <DownloadChapter>[];
        for (final chapterId in chapterIds) {
          final row = await _records.chapter(chapterId.value);
          if (row == null) {
            await _records.insertChapter(chapterId.value, bookId.value, now);
          } else {
            existing.add(row);
          }
        }
        return existing;
      });
      // A type known only now may change the rule of files already queued.
      await _applyRules();
      for (final row in existing) {
        await _requeue(
          row,
          row.state == DownloadState.failed
              ? DownloadEvent.retry
              : DownloadEvent.resume,
        );
      }
      // Inside the serial block, so a delete queued meanwhile unpins after.
      await _pinCover(bookId, book);
    });
    unawaited(_transfers.requestNotificationPermission());
    unawaited(_plan());
  }

  @override
  Future<void> enqueueBook(BookId bookId) async {
    final mark = _deletionMark(bookId);
    final ids = <ChapterId>[];
    String? cursor;
    do {
      final page = await _books.getBookChapters(
        bookId,
        ChapterPageOptions(cursor: cursor),
      );
      ids.addAll(page.data.map((c) => c.id));
      cursor = page.hasNextPage ? page.nextCursor : null;
    } while (cursor != null);
    await _enqueue(bookId, ids, mark);
  }

  @override
  Future<void> pause(DownloadScope scope) => _serial(() => _pauseIn(scope));

  /// Pauses the active chapters in [scope] in one transaction, then cancels
  /// their native tasks in one call.
  Future<void> _pauseIn(DownloadScope scope) async {
    final cancelled = <String>[];
    await _records.transaction(() async {
      for (final row in await _records.chaptersIn(scope)) {
        cancelled.addAll(await _applyEvent(row, DownloadEvent.pause) ?? []);
      }
    });
    await _cancelTasks(cancelled);
  }

  @override
  Future<void> resume(DownloadScope scope) =>
      _requeueAll(scope, DownloadEvent.resume);

  @override
  Future<void> retry(DownloadScope scope) =>
      _requeueAll(scope, DownloadEvent.retry);

  Future<void> _requeueAll(DownloadScope scope, DownloadEvent event) async {
    await _serial(() async {
      for (final row in await _records.chaptersIn(scope)) {
        await _requeue(row, event);
      }
    });
    unawaited(_plan());
  }

  @override
  Future<void> delete(DownloadScope scope) => _serial(() async {
    switch (scope) {
      case BookScope(:final bookId):
        _deletedBooks.update(bookId.value, (v) => v + 1, ifAbsent: () => 1);
      case AllScope():
        _deletedAll++;
      case ChaptersScope():
        break;
    }
    final rows = await _records.chaptersIn(scope);
    if (rows.isEmpty) return;
    await _cancelFiles([for (final r in rows) r.chapterId]);
    await _records.deleteChapters([for (final r in rows) r.chapterId]);
    for (final row in rows) {
      await _storage.deleteChapter(row.bookId, row.chapterId);
    }
    for (final bookId in {for (final r in rows) r.bookId}) {
      if (await _records.deleteBookIfEmpty(bookId)) {
        await _storage.deleteBook(bookId);
        await _covers.unpin(bookId, coverPinOwner);
      }
    }
  });

  /// Deletes every download: the server changed, and they belong to the old
  /// one. Cancels every native task, recorded or not.
  Future<void> clearAll() => _serial(() async {
    _deletedAll++;
    // Never throws (see TransferQueue); a task it misses is cancelled as an
    // orphan at the next start.
    await _transfers.cancelAll();
    final books = await _records.bookIds();
    await _records.clear();
    await _storage.deleteAll();
    for (final bookId in books) {
      await _covers.unpin(bookId, coverPinOwner);
    }
    AppLogger.i('Downloads cleared', _logTag);
  });

  // ---------------------------------------------------------------------------
  // Queries

  @override
  Stream<List<BookDownload>> watchAll() => Rx.combineLatest3(
    _records.watchRows(),
    _unmetered.distinct(),
    _rules.stream,
    _toBooks,
  );

  @override
  Stream<BookDownload?> watchBook(BookId bookId) => watchAll().map((books) {
    for (final book in books) {
      if (book.bookId == bookId) return book;
    }
    return null;
  }).distinct();

  @override
  Future<DownloadTotals> totals() => _records.totals();

  static List<BookDownload> _toBooks(
    List<ChapterDownloadRow> rows,
    bool unmetered,
    Map<BookType, DownloadNetwork> rules,
  ) {
    final byBook = <String, List<ChapterDownload>>{};
    for (final row in rows) {
      final waiting =
          !unmetered &&
          DownloadStateMachine.isActive(row.state) &&
          rules[row.bookType] == DownloadNetwork.unmetered;
      byBook
          .putIfAbsent(row.bookId, () => [])
          .add(
            ChapterDownload(
              chapterId: ChapterId(row.chapterId),
              bookId: BookId(row.bookId),
              state: row.state,
              reason: waiting
                  ? DownloadWaitReason.waitingForNetwork
                  : DownloadWaitReason.none,
              filesDone: row.filesDone,
              filesTotal: row.filesTotal,
              bytes: row.bytes,
              error: row.error,
            ),
          );
    }
    return [
      for (final entry in byBook.entries)
        BookDownload(bookId: BookId(entry.key), chapters: entry.value),
    ];
  }

  // ---------------------------------------------------------------------------
  // Planning

  /// Plans queued chapters, oldest first, [planConcurrency] manifests at a
  /// time, until none is left. When the server cannot be reached, it stops
  /// and tries again on reconnect or after [_planRetryDelay] (a slow request
  /// does not always end in a reconnect event).
  Future<void> _plan() async {
    // Backing off from an unreachable or busy server: only the retry timer
    // or a reconnect plans again, not every new command.
    if (_planRetry != null || _disposed) return;
    if (_planning) {
      _planAgain = true;
      return;
    }
    _planning = true;
    try {
      do {
        _planAgain = false;
        while (!_connectivity.isOffline && !_disposed) {
          final batch = await _records.unplanned(planConcurrency);
          if (batch.isEmpty) break;
          final outcomes = await Future.wait(batch.map(_fetchPlan));
          // A timeout flips the status offline until the confirming probe
          // answers: wait for it, so a slow chapter counts against itself
          // and a real outage does not.
          if (outcomes.any((o) => o is _Unreachable)) {
            await _confirmReachability();
          }
          // In FIFO order, so files reach the native queue in enqueue order.
          await _serial(() async {
            if (_disposed) return;
            for (final outcome in outcomes) {
              await _applyPlan(outcome);
            }
          });
          if (outcomes.any((o) => o is _Unreachable)) {
            _schedulePlanRetry();
            _planAgain = false;
            return;
          }
        }
      } while (_planAgain && !_connectivity.isOffline);
    } catch (e, stackTrace) {
      AppLogger.e('Planning downloads failed', e, stackTrace, _logTag);
      _schedulePlanRetry();
    } finally {
      _planning = false;
    }
  }

  Future<void> _confirmReachability() async {
    try {
      await _connectivity.checkNow();
    } catch (e, stackTrace) {
      AppLogger.e('Reachability probe failed', e, stackTrace, _logTag);
    }
  }

  void _schedulePlanRetry() {
    if (_disposed) return;
    _planRetry ??= Timer(_planRetryDelay, () {
      _planRetry = null;
      unawaited(_plan());
    });
  }

  Future<_PlanOutcome> _fetchPlan(DownloadChapter row) async {
    try {
      final manifest = await _remote.fetchManifest(row.chapterId);
      final files = ChapterFilePlan.of(ReadingChapterModel.fromJson(manifest));
      return _Planned(row.chapterId, manifest, files);
    } on NetworkException {
      return _Unreachable(row.chapterId);
    } on OfflineException {
      return _Unreachable(row.chapterId);
    } on TransientServerException {
      return _Unreachable(row.chapterId);
    } catch (e, stackTrace) {
      AppLogger.e('Could not plan a chapter download', e, stackTrace, _logTag);
      return _Failed(row.chapterId, _errorOf(e));
    }
  }

  /// Every outcome leaves the chapter planned or failed, except
  /// [_Unreachable], which does so after [maxTransientAttempts] while the
  /// server is reachable: the planning loop always advances.
  Future<void> _applyPlan(_PlanOutcome outcome) async {
    switch (outcome) {
      case _Unreachable(:final chapterId):
        // Offline is not the chapter's fault: wait without counting.
        if (_connectivity.isOffline) return;
        final failures = (_transientFailures[chapterId] ?? 0) + 1;
        if (failures < maxTransientAttempts) {
          _transientFailures[chapterId] = failures;
          return;
        }
        _transientFailures.remove(chapterId);
        await _fail(chapterId, DownloadErrors.server);
      case _Failed(:final chapterId, :final error):
        _transientFailures.remove(chapterId);
        await _fail(chapterId, error);
      case _Planned(:final chapterId, :final manifest, :final files):
        _transientFailures.remove(chapterId);
        // Deleted or planned meanwhile: the fresh row decides.
        final current = await _records.chapter(chapterId);
        if (current == null || current.planned) return;
        final int manifestBytes;
        try {
          manifestBytes = await _storage.writeManifest(
            current.bookId,
            chapterId,
            manifest,
          );
        } on FileSystemException catch (e, stackTrace) {
          AppLogger.e('Could not store a manifest', e, stackTrace, _logTag);
          await _fail(chapterId, _errorOf(e));
          return;
        }
        await _records.recordPlan(chapterId, manifestBytes, [
          for (final file in files)
            PlannedFile(
              position: file.position,
              url: _remote.resolve(file.url),
              directory: file.directory,
              filename: file.filename,
            ),
        ]);
        await _continue(chapterId);
    }
  }

  static String _errorOf(Object error) => switch (error) {
    UnauthorizedException() => DownloadErrors.signInRequired,
    ChapterUnavailableException() => DownloadErrors.notFound,
    FileSystemException() when _isDiskFull(error) => DownloadErrors.storageFull,
    AppExceptions() => DownloadErrors.server,
    _ => DownloadErrors.unknown,
  };

  /// ENOSPC is 28 on Linux, Android, macOS and iOS.
  static bool _isDiskFull(FileSystemException e) => e.osError?.errorCode == 28;

  // ---------------------------------------------------------------------------
  // Native events, reconciliation and rules (inside _serial)

  Future<void> _onTransfer(TransferEvent event) async {
    switch (event) {
      case TransfersResynced():
        await _resyncOrRetry();
      case TransferCancelled(:final taskId):
        await _onUserCancel({taskId});
      case TransferStarted(:final taskId):
        if (await _fileOf(taskId) case (final chapter, _)) {
          await _transition(chapter, DownloadEvent.fileStarted);
        }
      case TransferCompleted(:final taskId):
        if (await _fileOf(taskId) case (final chapter, final file)) {
          await _onFileDone(chapter, file);
        }
      case TransferFailed(:final taskId, :final error):
        if (await _fileOf(taskId) case (final chapter, _)) {
          await _failChapter(chapter, error);
        }
    }
  }

  /// Resyncs against the native queue; if the queue cannot be listed (it
  /// may fail, see TransferQueue), keeps the bindings and tries again later.
  Future<void> _resyncOrRetry() async {
    final Set<String> active;
    try {
      active = await _transfers.activeTaskIds();
    } catch (e, stackTrace) {
      AppLogger.e('Could not list native downloads', e, stackTrace, _logTag);
      _scheduleResyncRetry();
      return;
    }
    _resyncRetry?.cancel();
    _resyncRetry = null;
    await _resync(active);
  }

  /// The chapter and file of the current attempt [taskId]; `null` for an
  /// earlier attempt, cancelled or replaced.
  Future<(DownloadChapter, DownloadFile)?> _fileOf(String taskId) async {
    final file = await _records.fileForTask(taskId);
    if (file == null) return null;
    final chapter = await _records.chapter(file.chapterId);
    if (chapter == null) return null;
    return (chapter, file);
  }

  Future<void> _onFileDone(DownloadChapter chapter, DownloadFile file) async {
    final size = await _storage.sizeOf(
      chapter.bookId,
      chapter.chapterId,
      file.relativePath,
    );
    if (size == null) {
      await _failChapter(chapter, DownloadErrors.unknown);
      return;
    }
    await _records.markDone(file.fileId, size);
    await _continue(chapter.chapterId);
  }

  /// A cancel the app did not ask for (it unbinds ids before cancelling)
  /// came from the user, from the download notification, which covers all
  /// downloads: pause every active chapter, in one batch. What is on disk is
  /// kept and a resume continues it. Ids of earlier attempts are ignored.
  Future<void> _onUserCancel(Set<String> taskIds) async {
    if ((await _records.boundTaskIdsAmong(taskIds)).isEmpty) return;
    await _pauseIn(const DownloadScope.all());
  }

  /// Applies what happened while the app was not running (user cancels are
  /// applied before): files whose native task vanished are queued again,
  /// and [_continue] marks those on disk done. A file that failed while the
  /// app was closed is queued again, so it gets one more try.
  Future<void> _reconcile() async {
    await _healLostChapters();
    await _resyncOrRetry();
    // Files a cancelled task moved in after its chapter was deleted.
    await _storage.sweep(await _records.chapterKeys());
  }

  void _scheduleResyncRetry() {
    if (_disposed) return;
    _resyncRetry ??= Timer(_planRetryDelay, () {
      _resyncRetry = null;
      unawaited(_guard('Resync', () => _serial(_resyncOrRetry)));
    });
  }

  /// Planned chapters whose files are gone (a backup restored onto another
  /// device carries the records, not the files) are planned again: the
  /// manifest is fetched anew and every file downloaded. A done one becomes
  /// paused, so it no longer passes for downloaded and a resume fetches it;
  /// an active one is planned again right away (see [_isLost]).
  Future<void> _healLostChapters() async {
    final lost = <DownloadChapter>[];
    for (final planned in await _records.plannedChapterSamples()) {
      if (!await _isLost(planned)) continue;
      final chapter = await _records.chapter(planned.chapterId);
      if (chapter != null) lost.add(chapter);
    }
    await _replan(lost, DownloadEvent.lost);
  }

  /// Lost when the manifest or the last done file is missing: a restore
  /// drops every downloaded file, and a delete that failed half-way may
  /// leave either one behind.
  Future<bool> _isLost(PlannedChapterSample planned) async {
    for (final path in [DownloadStorage.manifestName, ?planned.sample]) {
      final size = await _storage.sizeOf(
        planned.bookId,
        planned.chapterId,
        path,
      );
      if (size == null) return true;
    }
    return false;
  }

  /// Plans [chapters] again from scratch, applying [event]. Each directory
  /// is deleted first, so a crash before the reset leaves the chapter
  /// planned with its files gone (the next start heals it) and old pages
  /// never pass for new ones. A chapter whose directory could not be
  /// deleted is left as it was, event not applied.
  Future<void> _replan(
    List<DownloadChapter> chapters,
    DownloadEvent event,
  ) async {
    if (chapters.isEmpty) return;
    // Stop their tasks first, so none lands an old file into the directory
    // being deleted; the ids are unbound before the cancel (crash-safe).
    await _cancelFiles([for (final c in chapters) c.chapterId]);
    final deleted = [
      for (final chapter in chapters)
        if (await _storage.deleteChapter(chapter.bookId, chapter.chapterId))
          chapter,
    ];
    if (deleted.isEmpty) return;
    await _records.transaction(() async {
      for (final chapter in deleted) {
        // Applies to done (lost) and failed (retry); active chapters keep
        // their state and are planned again.
        await _applyEvent(chapter, event);
        await _records.resetPlan(chapter.chapterId);
      }
    });
  }

  /// Files of active chapters whose task is no longer in [active] are queued
  /// again; [_continue] also marks those already on disk done.
  Future<void> _resync(Set<String> active) async {
    final recorded = await _records.recordedTaskIds();
    // Native tasks no active chapter points at: a cancel that never reached
    // the native queue, or a late duplicate. They must not run.
    final orphans = active.difference(recorded);
    await _cancelTasks(orphans.toList());
    await _records.releaseTaskIds(recorded.difference(active));
    for (final chapter in await _records.activePlanned()) {
      await _continue(chapter.chapterId);
    }
  }

  /// Loads and applies the rules inside one serial step, so two quick
  /// changes apply in order.
  Future<void> _onRulesChanged() => _serial(() async {
    final rules = await _loadRules();
    if (!_rules.isClosed) _rules.add(rules);
    await _applyRules();
  });

  /// Requeues the chapters with a queued file whose stored rule differs from
  /// what the current rules want for its book type.
  Future<void> _applyRules() async {
    final chapterIds = await _records.chaptersQueuedAgainstRules({
      for (final entry in _rules.value.entries)
        if (entry.value == DownloadNetwork.unmetered) entry.key,
    });
    await _cancelFiles(chapterIds);
    for (final chapterId in chapterIds) {
      await _continue(chapterId);
    }
  }

  Future<Map<BookType, DownloadNetwork>> _loadRules() async {
    final rules = <BookType, DownloadNetwork>{};
    for (final type in BookType.values) {
      try {
        rules[type] = await _policy.requirementFor(type);
      } catch (e, stackTrace) {
        AppLogger.e('Network rule unavailable', e, stackTrace, _logTag);
        rules[type] = DownloadNetwork.any;
      }
    }
    return rules;
  }

  // ---------------------------------------------------------------------------
  // Chapter steps (inside _serial)

  /// Applies [event] and moves the chapter on: a retry after `notFound`
  /// fetches the manifest again (the chapter may have been re-scraped);
  /// otherwise its missing files are queued again.
  Future<void> _requeue(DownloadChapter row, DownloadEvent event) async {
    if (event == DownloadEvent.retry &&
        row.state == DownloadState.failed &&
        row.error == DownloadErrors.notFound &&
        row.planned) {
      // The chapter may have been re-scraped: plan it again from scratch.
      // If its files cannot be deleted it stays failed, to retry later.
      return _replan([row], event);
    }
    if (await _transition(row, event)) await _continue(row.chapterId);
  }

  /// Moves a planned, active chapter forward: files on disk are marked done
  /// (one may land after its task was cancelled), the chapter is done when
  /// none is missing, and missing files without a native task are queued.
  /// An unplanned chapter waits for the planner.
  Future<void> _continue(String chapterId) async {
    final chapter = await _records.chapter(chapterId);
    if (chapter == null || !chapter.planned) return;
    if (!DownloadStateMachine.isActive(chapter.state)) return;

    final missing = <DownloadFile>[];
    for (final file in await _records.pendingFiles(chapterId)) {
      final size = file.nativeTaskId == null
          ? await _storage.sizeOf(chapter.bookId, chapterId, file.relativePath)
          : null;
      if (size != null) {
        await _records.markDone(file.fileId, size);
      } else {
        missing.add(file);
      }
    }
    if (missing.isEmpty) {
      await _transition(chapter, DownloadEvent.complete);
      return;
    }

    final unqueued = missing.where((f) => f.nativeTaskId == null).toList();
    if (unqueued.isEmpty) return;
    final type = await _records.bookType(chapter.bookId);
    final wifi = _rules.value[type] == DownloadNetwork.unmetered;
    final headers = _remote.fileHeaders;
    final transfers = <FileTransfer>[];
    final taskIds = <String, String>{};
    for (final file in unqueued) {
      // A new id per attempt (and per app session), so a late event from an
      // earlier attempt cannot pass for the current one.
      final taskId = '${file.fileId}@$_session.${++_attempt}';
      taskIds[file.fileId] = taskId;
      final target = DownloadStorage.transferTarget(
        chapter.bookId,
        chapterId,
        file.relativePath,
      );
      transfers.add(
        FileTransfer(
          taskId: taskId,
          url: file.url,
          headers: headers,
          directory: target.directory,
          filename: target.filename,
          requiresWiFi: wifi,
        ),
      );
    }
    await _records.assignTasks(taskIds, queuedOnWifi: wifi);
    await _transfers.enqueue(transfers);
  }

  /// Fails the chapter and cancels its other files; a retry downloads only
  /// what is missing.
  Future<void> _fail(String chapterId, String error) async {
    final chapter = await _records.chapter(chapterId);
    if (chapter != null) await _failChapter(chapter, error);
  }

  Future<void> _failChapter(DownloadChapter chapter, String error) async {
    await _transition(chapter, DownloadEvent.fail, error: error);
  }

  /// Unbinds the native tasks of the chapters' bound files and cancels them.
  /// The ids are cleared first, so any cancel events that follow are stale.
  Future<void> _cancelFiles(List<String> chapterIds) async {
    await _cancelTasks(await _records.releaseTasksOf(chapterIds));
  }

  Future<void> _cancelTasks(List<String> taskIds) async {
    if (taskIds.isNotEmpty) await _transfers.cancel(taskIds);
  }

  /// Applies [event] through [DownloadStateMachine]; `false` when it does not
  /// apply to the chapter's state. Leaving the active states clears the
  /// chapter's native task ids in the same write, so an inactive chapter
  /// never holds one; the unbound tasks are then cancelled.
  Future<bool> _transition(
    DownloadChapter chapter,
    DownloadEvent event, {
    String? error,
  }) async {
    final cleared = await _applyEvent(chapter, event, error: error);
    if (cleared == null) return false;
    await _cancelTasks(cleared);
    return true;
  }

  /// [_transition] without the cancel: returns the task ids it unbound, for
  /// the caller to cancel in a batch, or `null` when [event] does not apply.
  Future<List<String>?> _applyEvent(
    DownloadChapter chapter,
    DownloadEvent event, {
    String? error,
  }) async {
    final next = DownloadStateMachine.next(chapter.state, event);
    if (next == null) return null;
    return _records.setState(
      chapter.chapterId,
      next,
      next == DownloadState.failed ? error : null,
      clearTasks: !DownloadStateMachine.isActive(next),
    );
  }

  /// Keeps the cover, and the cached book row, while the book has downloads.
  Future<void> _pinCover(BookId bookId, Book? book) async {
    try {
      await _covers.pin(bookId.value, coverPinOwner);
    } catch (e, stackTrace) {
      AppLogger.e('Could not pin the cover', e, stackTrace, _logTag);
      return;
    }
    final cover = book?.cover?.value;
    if (cover == null || cover.isEmpty) return;
    // Not awaited: a slow cover must not hold the queue.
    unawaited(
      _covers
          .ensure(bookId.value, cover)
          .then<void>(
            (_) {},
            onError: (Object e, StackTrace stackTrace) =>
                AppLogger.e('Cover fetch failed', e, stackTrace, _logTag),
          ),
    );
  }

  // ---------------------------------------------------------------------------
  // Plumbing

  Future<Book?> _bookOrNull(BookId bookId) async {
    try {
      return await _books.getBook(bookId);
    } catch (e, stackTrace) {
      // Offline and not cached: the type is recorded on a later enqueue.
      AppLogger.e('Book details unavailable', e, stackTrace, _logTag);
      return null;
    }
  }

  /// Runs [action] after every action queued before it. Never call it from
  /// inside an action: that would wait on itself.
  Future<T> _serial<T>(Future<T> Function() action) {
    final result = _tail.then((_) => action());
    _tail = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  Future<void> _guard(String what, Future<void> Function() action) async {
    try {
      await action();
    } catch (e, stackTrace) {
      AppLogger.e('$what failed', e, stackTrace, _logTag);
    }
  }
}

/// What fetching a chapter's manifest gave.
sealed class _PlanOutcome {
  final String chapterId;

  const _PlanOutcome(this.chapterId);
}

class _Planned extends _PlanOutcome {
  final Map<String, dynamic> manifest;
  final List<PlannedFile> files;

  const _Planned(super.chapterId, this.manifest, this.files);
}

class _Failed extends _PlanOutcome {
  final String error;

  const _Failed(super.chapterId, this.error);
}

/// The server could not be reached, or asked to try later.
class _Unreachable extends _PlanOutcome {
  const _Unreachable(super.chapterId);
}
