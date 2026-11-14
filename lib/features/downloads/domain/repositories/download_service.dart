import '../../../books/domain/value_objects/book_id.dart';
import '../../../books/domain/value_objects/chapter_id.dart';
import '../entities/book_download.dart';
import '../entities/download_scope.dart';
import '../entities/download_totals.dart';

/// Downloads chapters for offline reading.
///
/// Files keep downloading when the app is closed. A chapter is the unit: it is
/// done once its manifest and every file are on disk. Downloads belong to the
/// configured server and are deleted when it changes.
abstract class DownloadService {
  /// Queues [chapterIds] of [bookId]. Chapters already downloading or done
  /// are left alone; paused or failed ones are queued again.
  Future<void> enqueueChapters(BookId bookId, List<ChapterId> chapterIds);

  /// Queues every chapter of [bookId], paging the chapter list itself.
  Future<void> enqueueBook(BookId bookId);

  /// Pauses queued and running chapters in [scope].
  Future<void> pause(DownloadScope scope);

  /// Queues paused chapters in [scope] again.
  Future<void> resume(DownloadScope scope);

  /// Queues failed chapters in [scope] again; only missing files download.
  Future<void> retry(DownloadScope scope);

  /// Cancels and deletes the chapters in [scope] with their files.
  Future<void> delete(DownloadScope scope);

  /// The downloads of [bookId], or `null` when it has none. Emits on listen,
  /// then on every change.
  Stream<BookDownload?> watchBook(BookId bookId);

  /// Every book with downloads, in order of first enqueue.
  Stream<List<BookDownload>> watchAll();

  /// Count and size of everything downloaded.
  Future<DownloadTotals> totals();
}
