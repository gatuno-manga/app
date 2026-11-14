import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/connectivity/connectivity_service.dart';
import '../../../../core/covers/cover_store.dart';
import '../../../../core/logging/logger.dart';
import '../../../../core/network/exceptions.dart';
import '../../../books/domain/entities/book.dart';
import '../../../books/domain/entities/book_type.dart';
import '../../../books/domain/entities/chapter_page_options.dart';
import '../../../books/domain/repositories/books_repository.dart';
import '../../../books/domain/value_objects/book_id.dart';
import '../../../books/domain/value_objects/chapter_id.dart';
import '../../../reading/data/models/reading_chapter_model.dart';
import '../../../reading/domain/entities/reading_chapter.dart';
import '../../../reading/domain/entities/reading_enums.dart';
import '../../domain/entities/book_download.dart';
import '../../domain/entities/chapter_download.dart';
import '../../domain/entities/download_network.dart';
import '../../domain/entities/download_scope.dart';
import '../../domain/entities/download_state.dart';
import '../../domain/entities/download_totals.dart';
import '../../domain/repositories/download_network_policy.dart';
import '../../domain/repositories/download_service.dart';
import '../../domain/use_cases/download_state_machine.dart';
import '../../exceptions/download_exceptions.dart';
import '../data_sources/download_remote_data_source.dart';
import '../data_sources/download_storage.dart';
import '../data_sources/transfer_queue.dart';
import '../database/downloads_database.dart';

/// [DownloadService] that plans chapters in Dart and hands their files to
/// the native [TransferQueue].
///
/// Planning a chapter fetches its manifest (`GET /chapters/:id`, through
/// `DioClient`), stores it, and records one row per file. That needs the app
/// running; the files then download natively, also with the app closed, and
/// their outcome is applied when events arrive or, on the next [start], by
/// checking what is on disk.
///
/// Every change to the records runs through [_serial], so a native event, a
/// user command and a finished plan never interleave.
class DownloadManager implements DownloadService {
  /// Owner of the cover pins this manager holds in [CoverStore].
  static const String coverPinOwner = 'download';

  /// Manifests fetched at once.
  static const int planConcurrency = 4;

  final DownloadsDatabase _db;
  final DownloadStorage _storage;
  final TransferQueue _transfers;
  final DownloadRemoteDataSource _remote;
  final BooksRepository _books;
  final CoverStore _covers;
  final DownloadNetworkPolicy _policy;
  final ConnectivityService _connectivity;
  final Stream<bool> _unmetered;
  final DateTime Function() _now;

  static const String _logTag = 'DownloadManager';

  Future<void> _tail = Future<void>.value();
  final List<StreamSubscription<Object?>> _subscriptions = [];
  final Map<BookType, DownloadNetwork> _rules = {};
  final BehaviorSubject<int> _rulesVersion = BehaviorSubject<int>.seeded(0);
  bool _planning = false;
  bool _planAgain = false;
  int _attempt = 0;

  DownloadManager({
    required DownloadsDatabase db,
    required DownloadStorage storage,
    required TransferQueue transfers,
    required DownloadRemoteDataSource remote,
    required BooksRepository books,
    required CoverStore covers,
    required DownloadNetworkPolicy policy,
    required ConnectivityService connectivity,
    required Stream<bool> unmetered,
    DateTime Function()? now,
  }) : _db = db,
       _storage = storage,
       _transfers = transfers,
       _remote = remote,
       _books = books,
       _covers = covers,
       _policy = policy,
       _connectivity = connectivity,
       _unmetered = unmetered,
       _now = now ?? DateTime.now;

  /// Listens to native events, applies what happened while the app was
  /// closed, and plans chapters left unplanned.
  Future<void> start() async {
    _subscriptions
      ..add(
        _transfers.events.listen(
          (event) =>
              _guard('Transfer event', () => _serial(() => _onTransfer(event))),
        ),
      )
      ..add(
        _policy.changes.listen(
          (_) => _guard('Network rule change', () => _serial(_reapplyRules)),
        ),
      )
      ..add(_connectivity.onReconnected.listen((_) => unawaited(_plan())));
    await _transfers.start();
    await _serial(_reconcile);
    unawaited(_plan());
  }

  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    await _rulesVersion.close();
  }

  // ---------------------------------------------------------------------------
  // Commands

  @override
  Future<void> enqueueChapters(
    BookId bookId,
    List<ChapterId> chapterIds,
  ) async {
    if (chapterIds.isEmpty) return;
    final book = await _bookOrNull(bookId);
    await _serial(() async {
      final now = _now();
      await _db
          .into(_db.downloadBooks)
          .insert(
            DownloadBooksCompanion.insert(
              bookId: bookId.value,
              bookType: _bookTypeOf(book).value,
              enqueuedAt: now,
            ),
            mode: InsertMode.insertOrIgnore,
          );
      for (final chapterId in chapterIds) {
        final row = await _chapter(chapterId.value);
        if (row == null) {
          await _db
              .into(_db.downloadChapters)
              .insert(
                DownloadChaptersCompanion.insert(
                  chapterId: chapterId.value,
                  bookId: bookId.value,
                  state: DownloadState.queued.name,
                  enqueuedAt: now,
                ),
              );
        } else {
          final state = _stateOf(row);
          final event = state == DownloadState.failed
              ? DownloadEvent.retry
              : DownloadEvent.resume;
          if (await _transition(row, event)) await _continue(row.chapterId);
        }
      }
    });
    await _pinCover(bookId, book);
    unawaited(_transfers.requestNotificationPermission());
    unawaited(_plan());
  }

  @override
  Future<void> enqueueBook(BookId bookId) async {
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
    await enqueueChapters(bookId, ids);
  }

  @override
  Future<void> pause(DownloadScope scope) => _serial(() async {
    for (final row in await _chaptersIn(scope)) {
      if (await _transition(row, DownloadEvent.pause)) {
        await _cancelFiles(row.chapterId);
      }
    }
  });

  @override
  Future<void> resume(DownloadScope scope) =>
      _requeue(scope, DownloadEvent.resume);

  @override
  Future<void> retry(DownloadScope scope) =>
      _requeue(scope, DownloadEvent.retry);

  Future<void> _requeue(DownloadScope scope, DownloadEvent event) async {
    await _serial(() async {
      for (final row in await _chaptersIn(scope)) {
        if (await _transition(row, event)) await _continue(row.chapterId);
      }
    });
    unawaited(_plan());
  }

  @override
  Future<void> delete(DownloadScope scope) => _serial(() async {
    final rows = await _chaptersIn(scope);
    if (rows.isEmpty) return;
    for (final row in rows) {
      await _cancelFiles(row.chapterId);
    }
    final ids = [for (final r in rows) r.chapterId];
    await _db.transaction(() async {
      await (_db.delete(
        _db.downloadFiles,
      )..where((f) => f.chapterId.isIn(ids))).go();
      await (_db.delete(
        _db.downloadChapters,
      )..where((c) => c.chapterId.isIn(ids))).go();
    });
    for (final row in rows) {
      await _storage.deleteChapter(row.bookId, row.chapterId);
    }
    for (final bookId in {for (final r in rows) r.bookId}) {
      final left =
          await (_db.select(_db.downloadChapters)
                ..where((c) => c.bookId.equals(bookId))
                ..limit(1))
              .get();
      if (left.isNotEmpty) continue;
      await (_db.delete(
        _db.downloadBooks,
      )..where((b) => b.bookId.equals(bookId))).go();
      await _storage.deleteBook(bookId);
      await _covers.unpin(bookId, coverPinOwner);
    }
  });

  /// Deletes every download: the server changed, and they belong to the old
  /// one. Cover pins go with #89's cache wipe.
  Future<void> clearAll() => _serial(() async {
    final queued = await (_db.select(
      _db.downloadFiles,
    )..where((f) => f.nativeTaskId.isNotNull())).get();
    await _transfers.cancel([for (final f in queued) f.nativeTaskId!]);
    final books = await _db.select(_db.downloadBooks).get();
    await _db.clearAll();
    await _storage.deleteAll();
    for (final book in books) {
      await _covers.unpin(book.bookId, coverPinOwner);
    }
    AppLogger.i('Downloads cleared', _logTag);
  });

  // ---------------------------------------------------------------------------
  // Queries

  @override
  Stream<List<BookDownload>> watchAll() {
    final rows = _db
        .customSelect(
          'SELECT c.chapter_id, c.book_id, c.state, c.error, c.manifest_bytes, '
          'b.book_type, COUNT(f.file_id) AS files_total, '
          'COALESCE(SUM(f.done), 0) AS files_done, '
          'COALESCE(SUM(f.bytes), 0) AS file_bytes '
          'FROM download_chapters c '
          'LEFT JOIN download_books b ON b.book_id = c.book_id '
          'LEFT JOIN download_files f ON f.chapter_id = c.chapter_id '
          'GROUP BY c.chapter_id '
          // Timestamps have second precision: rowid keeps insertion order.
          'ORDER BY b.enqueued_at, b.rowid, c.enqueued_at, c.rowid',
          readsFrom: {
            _db.downloadChapters,
            _db.downloadBooks,
            _db.downloadFiles,
          },
        )
        .watch();
    return Rx.combineLatest3(
      rows,
      _unmetered.startWith(false).distinct(),
      _rulesVersion.stream,
      (rows, unmetered, _) => (rows, unmetered),
    ).asyncMap((input) => _toBooks(input.$1, input.$2));
  }

  @override
  Stream<BookDownload?> watchBook(BookId bookId) => watchAll().map((books) {
    for (final book in books) {
      if (book.bookId == bookId) return book;
    }
    return null;
  }).distinct();

  @override
  Future<DownloadTotals> totals() async {
    final row = await _db
        .customSelect(
          'SELECT (SELECT COUNT(*) FROM download_chapters) AS chapters, '
          '(SELECT COALESCE(SUM(manifest_bytes), 0) FROM download_chapters) + '
          '(SELECT COALESCE(SUM(bytes), 0) FROM download_files) AS bytes',
          readsFrom: {_db.downloadChapters, _db.downloadFiles},
        )
        .getSingle();
    return DownloadTotals(
      chapters: row.read<int>('chapters'),
      bytes: row.read<int>('bytes'),
    );
  }

  Future<List<BookDownload>> _toBooks(
    List<QueryRow> rows,
    bool unmetered,
  ) async {
    final byBook = <String, List<ChapterDownload>>{};
    for (final row in rows) {
      final state = DownloadState.values.byName(row.read<String>('state'));
      final type = _parseType(row.readNullable<String>('book_type'));
      final waiting =
          DownloadStateMachine.isActive(state) &&
          !unmetered &&
          await _requirement(type) == DownloadNetwork.unmetered;
      final bookId = row.read<String>('book_id');
      byBook
          .putIfAbsent(bookId, () => [])
          .add(
            ChapterDownload(
              chapterId: ChapterId(row.read<String>('chapter_id')),
              bookId: BookId(bookId),
              state: state,
              reason: waiting
                  ? DownloadWaitReason.waitingForNetwork
                  : DownloadWaitReason.none,
              filesDone: row.read<int>('files_done'),
              filesTotal: row.read<int>('files_total'),
              bytes:
                  row.read<int>('manifest_bytes') + row.read<int>('file_bytes'),
              error: row.readNullable<String>('error'),
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

  /// Plans queued chapters, oldest first, [planConcurrency] at a time, until
  /// none is left or the server is unreachable (then [ConnectivityService]'s
  /// reconnect starts it again).
  Future<void> _plan() async {
    if (_planning) {
      _planAgain = true;
      return;
    }
    _planning = true;
    try {
      do {
        _planAgain = false;
        while (!_connectivity.isOffline) {
          final batch =
              await (_db.select(_db.downloadChapters)
                    ..where(
                      (c) =>
                          c.state.equals(DownloadState.queued.name) &
                          c.planned.equals(false),
                    )
                    ..orderBy([
                      (c) => OrderingTerm.asc(c.enqueuedAt),
                      (_) => OrderingTerm.asc(_rowId),
                    ])
                    ..limit(planConcurrency))
                  .get();
          if (batch.isEmpty) break;
          final reachable = await Future.wait(batch.map(_planOne));
          if (reachable.contains(false)) break;
        }
      } while (_planAgain && !_connectivity.isOffline);
    } catch (e, stackTrace) {
      AppLogger.e('Planning downloads failed', e, stackTrace, _logTag);
    } finally {
      _planning = false;
    }
  }

  /// Plans one chapter. Returns `false` when the server could not be reached:
  /// the chapter stays queued and unplanned. Any other outcome leaves the
  /// chapter planned or failed, so the planning loop always advances.
  Future<bool> _planOne(DownloadChapter row) async {
    final Map<String, dynamic> manifest;
    final List<_PlannedFile> files;
    try {
      manifest = await _remote.fetchManifest(row.chapterId);
      files = _filesOf(ReadingChapterModel.fromJson(manifest));
    } on NetworkException {
      return false;
    } on OfflineException {
      return false;
    } catch (e, stackTrace) {
      AppLogger.e('Could not plan a chapter download', e, stackTrace, _logTag);
      await _serial(() => _fail(row.chapterId, _errorOf(e)));
      return true;
    }

    await _serial(() async {
      // Deleted, paused or planned meanwhile: the fresh row decides.
      final current = await _chapter(row.chapterId);
      if (current == null || current.planned) return;
      final int manifestBytes;
      try {
        manifestBytes = await _storage.writeManifest(
          current.bookId,
          current.chapterId,
          manifest,
        );
      } on FileSystemException catch (e, stackTrace) {
        AppLogger.e(
          'Could not store a chapter manifest',
          e,
          stackTrace,
          _logTag,
        );
        await _fail(current.chapterId, DownloadErrors.storageFull);
        return;
      }
      await _db.transaction(() async {
        for (final file in files) {
          await _db
              .into(_db.downloadFiles)
              .insert(
                DownloadFilesCompanion.insert(
                  fileId: '${current.chapterId}/${file.position}',
                  chapterId: current.chapterId,
                  position: file.position,
                  url: _remote.resolve(file.url),
                  relativePath: file.relativePath,
                ),
                mode: InsertMode.insertOrReplace,
              );
        }
        await (_db.update(
          _db.downloadChapters,
        )..where((c) => c.chapterId.equals(current.chapterId))).write(
          DownloadChaptersCompanion(
            planned: const Value(true),
            manifestBytes: Value(manifestBytes),
          ),
        );
      });
      if (DownloadStateMachine.isActive(_stateOf(current))) {
        await _continue(current.chapterId);
      }
    });
    return true;
  }

  /// The files of [chapter]; throws [ChapterUnavailableException] when it
  /// has no content to download yet (still being scraped, for example).
  static List<_PlannedFile> _filesOf(ReadingChapter chapter) {
    final id = chapter.id.value;
    switch (chapter.contentType) {
      case ContentType.image:
        final pages = [...chapter.pages]
          ..sort((a, b) => a.index.value.compareTo(b.index.value));
        if (pages.isEmpty) throw ChapterUnavailableException(id);
        return [
          for (final (i, page) in pages.indexed)
            _PlannedFile(
              position: i + 1,
              url: page.url.value,
              relativePath:
                  'pages/${(i + 1).toString().padLeft(4, '0')}.'
                  '${_extensionOf(page.url.value)}',
            ),
        ];
      case ContentType.document:
        final path = chapter.documentPath?.value;
        if (path == null || path.isEmpty) throw ChapterUnavailableException(id);
        return [
          _PlannedFile(
            position: 0,
            url: path,
            relativePath:
                'document.${chapter.documentFormat?.value ?? _extensionOf(path)}',
          ),
        ];
      case ContentType.text:
        // The text is inline in the manifest.
        if (chapter.content == null) throw ChapterUnavailableException(id);
        return const [];
    }
  }

  static String _extensionOf(String url) {
    final path = Uri.tryParse(url)?.path ?? '';
    final dot = path.lastIndexOf('.');
    if (dot == -1 || dot < path.lastIndexOf('/')) return 'img';
    final ext = path.substring(dot + 1).toLowerCase();
    return RegExp(r'^[a-z0-9]{1,5}$').hasMatch(ext) ? ext : 'img';
  }

  static String _errorOf(Object error) => switch (error) {
    UnauthorizedException() => DownloadErrors.signInRequired,
    ChapterUnavailableException() => DownloadErrors.notFound,
    FileSystemException() => DownloadErrors.storageFull,
    AppExceptions() => DownloadErrors.server,
    _ => DownloadErrors.unknown,
  };

  // ---------------------------------------------------------------------------
  // Native events and reconciliation (all inside _serial)

  Future<void> _onTransfer(TransferEvent event) async {
    final file = await (_db.select(
      _db.downloadFiles,
    )..where((f) => f.nativeTaskId.equals(event.taskId))).getSingleOrNull();
    // A cancelled or replaced attempt.
    if (file == null) return;
    final chapter = await _chapter(file.chapterId);
    if (chapter == null) return;

    switch (event) {
      case TransferStarted():
        await _transition(chapter, DownloadEvent.fileStarted);
      case TransferCompleted():
        final size = await _storage.sizeOf(
          chapter.bookId,
          chapter.chapterId,
          file.relativePath,
        );
        if (size == null) {
          await _fail(chapter.chapterId, DownloadErrors.unknown);
          return;
        }
        await _markDone(file.fileId, size);
        if (DownloadStateMachine.isActive(_stateOf(chapter))) {
          await _completeIfDone(chapter.chapterId);
        }
      case TransferFailed(:final error):
        await _fail(chapter.chapterId, error);
      case TransferCancelled():
        // Not cancelled by us (we clear the id first): the user cancelled
        // from the notification. Treat it as a pause, so nothing is lost.
        await _setTask(file.fileId, null);
        if (await _transition(chapter, DownloadEvent.pause)) {
          await _cancelFiles(chapter.chapterId);
        }
    }
  }

  /// Applies what happened while the app was not running: files on disk are
  /// done, and files whose native task vanished are queued again.
  Future<void> _reconcile() async {
    final active = await _transfers.activeTaskIds();
    final chapters =
        await (_db.select(_db.downloadChapters)..where(
              (c) =>
                  c.planned.equals(true) &
                  c.state.isIn([
                    DownloadState.queued.name,
                    DownloadState.running.name,
                  ]),
            ))
            .get();
    for (final chapter in chapters) {
      for (final file in await _pendingFiles(chapter.chapterId)) {
        final size = await _storage.sizeOf(
          chapter.bookId,
          chapter.chapterId,
          file.relativePath,
        );
        if (size != null) {
          await _markDone(file.fileId, size);
        } else if (file.nativeTaskId != null &&
            !active.contains(file.nativeTaskId)) {
          await _setTask(file.fileId, null);
        }
      }
      await _continue(chapter.chapterId);
    }
  }

  /// Cancels the queued files of every active chapter and queues them again
  /// under the new network rule.
  Future<void> _reapplyRules() async {
    _rules.clear();
    if (!_rulesVersion.isClosed) _rulesVersion.add(_rulesVersion.value + 1);
    final chapters =
        await (_db.select(_db.downloadChapters)..where(
              (c) =>
                  c.planned.equals(true) &
                  c.state.isIn([
                    DownloadState.queued.name,
                    DownloadState.running.name,
                  ]),
            ))
            .get();
    for (final chapter in chapters) {
      await _cancelFiles(chapter.chapterId);
      await _continue(chapter.chapterId);
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers (inside _serial)

  /// Moves a planned, active chapter forward: done when every file is on
  /// disk, otherwise queues its files that have no native task. An
  /// unplanned chapter waits for the planner.
  Future<void> _continue(String chapterId) async {
    final chapter = await _chapter(chapterId);
    if (chapter == null || !chapter.planned) return;
    if (!DownloadStateMachine.isActive(_stateOf(chapter))) return;
    final pending = <DownloadFile>[];
    for (final file in await _pendingFiles(chapterId)) {
      // Finished after its task was cancelled (a pause racing the download).
      final size = file.nativeTaskId == null
          ? await _storage.sizeOf(chapter.bookId, chapterId, file.relativePath)
          : null;
      if (size != null) {
        await _markDone(file.fileId, size);
      } else {
        pending.add(file);
      }
    }
    if (pending.isEmpty) {
      await _transition(chapter, DownloadEvent.complete);
      return;
    }
    final unqueued = pending.where((f) => f.nativeTaskId == null).toList();
    if (unqueued.isEmpty) return;
    final type = await _bookType(chapter.bookId);
    final wifi = await _requirement(type) == DownloadNetwork.unmetered;
    final headers = _remote.fileHeaders;
    final transfers = <FileTransfer>[];
    for (final file in unqueued) {
      final taskId = TransferIds.forAttempt(file.fileId, ++_attempt);
      await _setTask(file.fileId, taskId);
      final slash = file.relativePath.lastIndexOf('/');
      transfers.add(
        FileTransfer(
          taskId: taskId,
          url: file.url,
          headers: headers,
          directory: [
            DownloadStorage.chapterPath(chapter.bookId, chapterId),
            if (slash != -1) file.relativePath.substring(0, slash),
          ].join('/'),
          filename: file.relativePath.substring(slash + 1),
          group: chapterId,
          requiresWiFi: wifi,
        ),
      );
    }
    await _transfers.enqueue(transfers);
  }

  Future<void> _completeIfDone(String chapterId) async {
    if ((await _pendingFiles(chapterId)).isNotEmpty) return;
    final chapter = await _chapter(chapterId);
    if (chapter != null) await _transition(chapter, DownloadEvent.complete);
  }

  /// Fails the chapter and cancels its other files; a retry downloads only
  /// what is missing.
  Future<void> _fail(String chapterId, String error) async {
    final chapter = await _chapter(chapterId);
    if (chapter == null) return;
    if (await _transition(chapter, DownloadEvent.fail, error: error)) {
      await _cancelFiles(chapterId);
    }
  }

  /// Cancels the native tasks of the chapter's pending files. Their ids are
  /// cleared first, so the cancel events that follow are recognized as ours.
  Future<void> _cancelFiles(String chapterId) async {
    final queued = (await _pendingFiles(
      chapterId,
    )).where((f) => f.nativeTaskId != null).toList();
    if (queued.isEmpty) return;
    for (final file in queued) {
      await _setTask(file.fileId, null);
    }
    await _transfers.cancel([for (final f in queued) f.nativeTaskId!]);
  }

  /// Applies [event] through [DownloadStateMachine]; `false` when it does not
  /// apply to the chapter's state.
  Future<bool> _transition(
    DownloadChapter chapter,
    DownloadEvent event, {
    String? error,
  }) async {
    final next = DownloadStateMachine.next(_stateOf(chapter), event);
    if (next == null) return false;
    await (_db.update(
      _db.downloadChapters,
    )..where((c) => c.chapterId.equals(chapter.chapterId))).write(
      DownloadChaptersCompanion(
        state: Value(next.name),
        error: Value(next == DownloadState.failed ? error : null),
      ),
    );
    return true;
  }

  Future<void> _markDone(String fileId, int bytes) async {
    await (_db.update(
      _db.downloadFiles,
    )..where((f) => f.fileId.equals(fileId))).write(
      DownloadFilesCompanion(
        done: const Value(true),
        bytes: Value(bytes),
        nativeTaskId: const Value(null),
      ),
    );
  }

  Future<void> _setTask(String fileId, String? taskId) async {
    await (_db.update(_db.downloadFiles)..where((f) => f.fileId.equals(fileId)))
        .write(DownloadFilesCompanion(nativeTaskId: Value(taskId)));
  }

  Future<List<DownloadFile>> _pendingFiles(String chapterId) =>
      (_db.select(_db.downloadFiles)
            ..where((f) => f.chapterId.equals(chapterId) & f.done.equals(false))
            ..orderBy([(f) => OrderingTerm.asc(f.position)]))
          .get();

  Future<DownloadChapter?> _chapter(String chapterId) => (_db.select(
    _db.downloadChapters,
  )..where((c) => c.chapterId.equals(chapterId))).getSingleOrNull();

  Future<List<DownloadChapter>> _chaptersIn(DownloadScope scope) {
    final query = _db.select(_db.downloadChapters);
    switch (scope) {
      case ChaptersScope(:final chapterIds):
        query.where(
          (c) => c.chapterId.isIn([for (final id in chapterIds) id.value]),
        );
      case BookScope(:final bookId):
        query.where((c) => c.bookId.equals(bookId.value));
      case AllScope():
        break;
    }
    query.orderBy([
      (c) => OrderingTerm.asc(c.enqueuedAt),
      (_) => OrderingTerm.asc(_rowId),
    ]);
    return query.get();
  }

  Future<BookType> _bookType(String bookId) async {
    final row = await (_db.select(
      _db.downloadBooks,
    )..where((b) => b.bookId.equals(bookId))).getSingleOrNull();
    return _parseType(row?.bookType);
  }

  Future<DownloadNetwork> _requirement(BookType type) async {
    final cached = _rules[type];
    if (cached != null) return cached;
    try {
      return _rules[type] = await _policy.requirementFor(type);
    } catch (e, stackTrace) {
      AppLogger.e('Network rule unavailable', e, stackTrace, _logTag);
      return DownloadNetwork.any;
    }
  }

  // ---------------------------------------------------------------------------
  // Outside _serial

  Future<Book?> _bookOrNull(BookId bookId) async {
    try {
      return await _books.getBook(bookId);
    } catch (e, stackTrace) {
      // Offline and not cached: the book type falls back to `other`.
      AppLogger.e('Book details unavailable', e, stackTrace, _logTag);
      return null;
    }
  }

  /// Keeps the cover, and the cached book row, while the book has downloads.
  Future<void> _pinCover(BookId bookId, Book? book) async {
    try {
      await _covers.pin(bookId.value, coverPinOwner);
      final cover = book?.cover?.value;
      if (cover != null && cover.isNotEmpty) {
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
    } catch (e, stackTrace) {
      AppLogger.e('Could not pin the cover', e, stackTrace, _logTag);
    }
  }

  /// Runs [action] after every action queued before it.
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

  /// Insertion order; `enqueuedAt` only has second precision.
  static const Expression<int> _rowId = CustomExpression<int>('rowid');

  static DownloadState _stateOf(DownloadChapter row) =>
      DownloadState.values.byName(row.state);

  static BookType _bookTypeOf(Book? book) {
    final type = book?.type;
    if (type == null) return BookType.other;
    return switch (type) {
      TypeBook.manga => BookType.manga,
      TypeBook.manhwa => BookType.manhwa,
      TypeBook.manhua => BookType.manhua,
      TypeBook.book => BookType.book,
      TypeBook.other => BookType.other,
    };
  }

  static BookType _parseType(String? value) {
    for (final type in BookType.values) {
      if (type.value == value) return type;
    }
    return BookType.other;
  }
}

class _PlannedFile {
  final int position;
  final String url;
  final String relativePath;

  const _PlannedFile({
    required this.position,
    required this.url,
    required this.relativePath,
  });
}
