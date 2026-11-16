import 'dart:async';

import '../../../../core/logging/logger.dart';
import '../../../books/domain/value_objects/book_id.dart';
import '../../../books/domain/value_objects/chapter_id.dart';
import '../entities/auto_download_check_state.dart';
import '../entities/chapter_download.dart';
import '../entities/download_scope.dart';
import '../entities/listed_chapter.dart';
import '../repositories/download_service.dart';
import '../repositories/new_chapter_ledger.dart';
import '../repositories/new_chapter_source.dart';
import 'new_chapter_detection.dart';

/// How a new-chapter check ended.
enum NewChapterCheckOutcome {
  /// Every book was read (some may have been skipped, see the log).
  done,

  /// Not run: every book was checked recently, or none has it on.
  skipped,

  /// Nobody is signed in: nothing was read or written. The next check after
  /// signing in catches up.
  signedOut,

  /// No server is configured.
  noServer,

  /// The server changed during the check, which stopped writing.
  serverChanged,

  /// The deadline came first, or the run was asked to stop; the books not
  /// read go first next time.
  stopped,

  /// The server, or the local records, could not be read.
  failed,
}

/// The result of one new-chapter check.
class NewChapterCheckResult {
  final NewChapterCheckOutcome outcome;

  /// Chapters handed to [DownloadService.enqueueChapters], by book.
  final Map<BookId, List<ChapterId>> queued;

  const NewChapterCheckResult(this.outcome, {this.queued = const {}});
}

/// Finds new chapters of the books with automatic download on and queues
/// them (see [decideNewChapters] for what "new" means).
///
/// One check runs at a time: a call made while one runs starts after it.
/// Books are read in batches of [NewChapterSource.maxBooks], the least
/// recently checked first, so a check cut short by its deadline continues
/// where it stopped.
class NewChapterCheck {
  final NewChapterLedger _ledger;
  final NewChapterSource _source;
  final DownloadService _downloads;
  final Future<bool> Function() _signedIn;
  final String? Function() _server;
  final DateTime Function() _now;

  static const String _logTag = 'NewChapterCheck';

  Future<void> _tail = Future<void>.value();

  /// When this isolate last started a full check, whatever its outcome.
  DateTime? _lastFullAttempt;

  NewChapterCheck({
    required NewChapterLedger ledger,
    required NewChapterSource source,
    required DownloadService downloads,
    required Future<bool> Function() signedIn,
    required String? Function() server,
    DateTime Function()? now,
  }) : _ledger = ledger,
       _source = source,
       _downloads = downloads,
       _signedIn = signedIn,
       _server = server,
       _now = now ?? DateTime.now;

  /// Checks every book with automatic download on, or only [only]. Stops
  /// before the next book once [deadline] has passed or [stopRequested]
  /// says so. Never throws: a failure is logged and returned as
  /// [NewChapterCheckOutcome.failed].
  Future<NewChapterCheckResult> run({
    BookId? only,
    DateTime? deadline,
    bool Function()? stopRequested,
  }) => _serial(
    () => _guarded(
      () => _run(only: only, deadline: deadline, stopRequested: stopRequested),
    ),
  );

  /// Runs a full check unless every book was checked, or a full check was
  /// tried, less than [maxAge] ago ([NewChapterCheckOutcome.skipped]). A
  /// failed check counts as tried, so a server answering errors is not asked
  /// again on every resume.
  Future<NewChapterCheckResult> runIfStale(Duration maxAge) => _serial(
    () => _guarded(() async {
      bool fresh(DateTime? at) => at != null && _now().difference(at) < maxAge;
      if (fresh(_lastFullAttempt)) return _skipped;
      final books = await _ledger.books();
      // Never checked books come first, then the least recently checked.
      if (books.isEmpty || fresh(books.first.checkedAt)) return _skipped;
      return _run();
    }),
  );

  static const NewChapterCheckResult _skipped = NewChapterCheckResult(
    NewChapterCheckOutcome.skipped,
  );

  Future<NewChapterCheckResult> _guarded(
    Future<NewChapterCheckResult> Function() action,
  ) async {
    try {
      return await action();
    } catch (e, stackTrace) {
      AppLogger.e('Check failed', e, stackTrace, _logTag);
      return const NewChapterCheckResult(NewChapterCheckOutcome.failed);
    }
  }

  Future<T> _serial<T>(Future<T> Function() action) {
    final result = _tail.then((_) => action());
    _tail = result.then<void>((_) {}, onError: (_) {});
    return result;
  }

  Future<NewChapterCheckResult> _run({
    BookId? only,
    DateTime? deadline,
    bool Function()? stopRequested,
  }) async {
    if (!await _signedIn()) {
      AppLogger.i('Skipped: signed out', _logTag);
      return const NewChapterCheckResult(NewChapterCheckOutcome.signedOut);
    }
    if (only == null) _lastFullAttempt = _now();
    final server = _server();
    if (server == null) {
      return const NewChapterCheckResult(NewChapterCheckOutcome.noServer);
    }
    final books = [
      for (final book in await _ledger.books())
        if (only == null || book.bookId == only) book,
    ];
    final queued = <BookId, List<ChapterId>>{};
    NewChapterCheckResult result(NewChapterCheckOutcome outcome) =>
        NewChapterCheckResult(outcome, queued: queued);

    bool mustStop() =>
        (deadline != null && !_now().isBefore(deadline)) ||
        (stopRequested?.call() ?? false);

    for (var i = 0; i < books.length; i += NewChapterSource.maxBooks) {
      if (mustStop()) {
        AppLogger.i('Stopped after $i of ${books.length} books', _logTag);
        return result(NewChapterCheckOutcome.stopped);
      }
      final batch = books.skip(i).take(NewChapterSource.maxBooks).toList();
      final Map<BookId, List<ListedChapter>> listed;
      try {
        listed = await _source.chaptersOf([for (final b in batch) b.bookId]);
      } catch (e, stackTrace) {
        AppLogger.e('Could not list chapters', e, stackTrace, _logTag);
        return result(NewChapterCheckOutcome.failed);
      }
      for (final book in batch) {
        if (mustStop()) {
          AppLogger.i('Stopped within a batch', _logTag);
          return result(NewChapterCheckOutcome.stopped);
        }
        if (_server() != server) {
          AppLogger.i('Server changed: stopped', _logTag);
          return result(NewChapterCheckOutcome.serverChanged);
        }
        final chapters = listed[book.bookId];
        if (chapters == null) {
          // Deleted on the server or hidden from this user: keep the
          // setting, and let the other books go first next time.
          AppLogger.w('Book ${book.bookId.value} not returned', _logTag);
          await _ledger.record(
            book,
            chapters: const {},
            baseline: false,
            at: _now(),
          );
          continue;
        }
        final ids = await _checkBook(book, chapters, server);
        if (ids.isNotEmpty) queued[book.bookId] = ids;
      }
    }
    if (queued.isNotEmpty) {
      AppLogger.i(
        'Queued ${queued.values.fold(0, (n, ids) => n + ids.length)} new '
        'chapters of ${queued.length} books',
        _logTag,
      );
    }
    return result(NewChapterCheckOutcome.done);
  }

  /// Checks one book; the chapters it queued.
  Future<List<ChapterId>> _checkBook(
    AutoDownloadCheckState book,
    List<ListedChapter> listed,
    String server,
  ) async {
    try {
      final downloads = await _downloads.watchBook(book.bookId).first;
      final decision = decideNewChapters(
        listed: listed,
        seen: book.hasBaseline ? await _ledger.seen(book.bookId) : const {},
        downloaded: {
          for (final chapter
              in downloads?.chapters ?? const <ChapterDownload>[])
            chapter.chapterId,
        },
        hasBaseline: book.hasBaseline,
      );
      if (decision.queue.isNotEmpty) {
        // A chapter id of the old server means nothing on the new one, and
        // a book turned off (or on again) since the check began gets
        // nothing.
        if (_server() != server || !await _ledger.isCurrent(book)) {
          return const [];
        }
        // Queued before it is recorded: a failure here leaves it new, so the
        // next check tries again instead of losing it.
        await _downloads.enqueueChapters(book.bookId, decision.queue);
      }
      final recorded = await _ledger.record(
        book,
        chapters: decision.record,
        baseline: !book.hasBaseline,
        at: _now(),
      );
      if (!recorded) {
        // Turned off or on again while queueing: take the chapters back.
        AppLogger.i('Book ${book.bookId.value} changed meanwhile', _logTag);
        if (decision.queue.isNotEmpty) {
          await _downloads.delete(DownloadScope.chapters(decision.queue));
        }
        return const [];
      }
      return decision.queue;
    } catch (e, stackTrace) {
      AppLogger.e(
        'Check of book ${book.bookId.value} failed',
        e,
        stackTrace,
        _logTag,
      );
      return const [];
    }
  }
}
