import 'dart:async';

import '../../../books/domain/value_objects/book_id.dart';
import '../../../books/domain/value_objects/chapter_id.dart';
import '../entities/chapter_download.dart';
import '../entities/download_state.dart';
import '../repositories/download_service.dart';

/// Waits until every chapter in [chapters] is planned (its files are with
/// the native queue, or it is done, failed or paused), until [deadline], or
/// until [stopped] completes.
///
/// A background run must not end while chapters are still being planned:
/// planning needs the app, the files then download without it.
Future<void> awaitPlanned(
  DownloadService downloads,
  Map<BookId, List<ChapterId>> chapters, {
  required DateTime deadline,
  Future<void>? stopped,
  DateTime Function() now = DateTime.now,
}) async {
  var stop = false;
  unawaited(stopped?.then((_) => stop = true));
  for (final MapEntry(key: bookId, value: ids) in chapters.entries) {
    final left = deadline.difference(now());
    if (left <= Duration.zero || stop) return;
    final wanted = ids.toSet();
    try {
      final planned = downloads.watchBook(bookId).firstWhere((book) {
        final planned = {
          for (final chapter in book?.chapters ?? const <ChapterDownload>[])
            if (_isPlanned(chapter)) chapter.chapterId,
        };
        return planned.containsAll(wanted);
      });
      // Its error, if the stop came first, has nobody to report to.
      planned.ignore();
      await Future.any<Object?>([planned, ?stopped]).timeout(left);
    } on TimeoutException {
      return;
    } on StateError {
      // The stream ended (the downloads were wiped): nothing left to wait for.
    }
  }
}

bool _isPlanned(ChapterDownload chapter) =>
    chapter.filesTotal > 0 ||
    chapter.state == DownloadState.done ||
    chapter.state == DownloadState.failed ||
    chapter.state == DownloadState.paused;
