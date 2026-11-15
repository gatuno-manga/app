import 'dart:async';

import '../../../../core/logging/logger.dart';
import '../../../books/domain/value_objects/book_id.dart';
import '../../../books/domain/value_objects/chapter_id.dart';
import '../entities/auto_download_check_state.dart';
import '../entities/chapter_download.dart';
import '../entities/listed_chapter.dart';
import '../repositories/download_service.dart';
import '../repositories/new_chapter_ledger.dart';
import '../repositories/new_chapter_source.dart';
import 'new_chapter_detection.dart';

/// How a new-chapter check ended.
enum NewChapterCheckOutcome {
  /// Every book was read (some may have been skipped, see the log).
  done,

  /// Nobody is signed in: nothing was read or written. The next check after
  /// signing in catches up.
  signedOut,

  /// No server is configured.
  noServer,

  /// The server changed during the check, which stopped writing.
  serverChanged,

  /// The deadline came first; the books not read go first next time.
  outOfTime,

  /// The server could not be read.
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
  /// before reading another batch once [deadline] has passed.
  Future<NewChapterCheckResult> run({BookId? only, DateTime? deadline}) =>
      _serial(() => _run(only: only, deadline: deadline));

  /// Runs a full check unless one ran less than [maxAge] ago; `null` when
  /// skipped.
  Future<NewChapterCheckResult?> runIfStale(Duration maxAge) =>
      _serial(() async {
        final last = await _ledger.lastCheck();
        if (last != null && _now().difference(last) < maxAge) return null;
        return _run();
      });

  Future<T> _serial<T>(Future<T> Function() action) {
    final result = _tail.then((_) => action());
    _tail = result.then<void>((_) {}, onError: (_) {});
    return result;
  }

  Future<NewChapterCheckResult> _run({BookId? only, DateTime? deadline}) async {
    if (!await _signedIn()) {
      AppLogger.i('Skipped: signed out', _logTag);
      return const NewChapterCheckResult(NewChapterCheckOutcome.signedOut);
    }
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

    for (var i = 0; i < books.length; i += NewChapterSource.maxBooks) {
      if (deadline != null && !_now().isBefore(deadline)) {
        AppLogger.i('Out of time after $i of ${books.length} books', _logTag);
        return result(NewChapterCheckOutcome.outOfTime);
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
        if (_server() != server) {
          AppLogger.i('Server changed: stopped', _logTag);
          return result(NewChapterCheckOutcome.serverChanged);
        }
        final chapters = listed[book.bookId];
        if (chapters == null) {
          // Deleted on the server or hidden from this user: keep the setting.
          AppLogger.w('Book ${book.bookId.value} not returned', _logTag);
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
        // A chapter id of the old server means nothing on the new one.
        if (_server() != server) return const [];
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
        AppLogger.i('Book ${book.bookId.value} changed meanwhile', _logTag);
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
