import '../../../books/domain/value_objects/chapter_id.dart';
import '../entities/chapter_read_batch_result.dart';
import '../entities/opened_chapter.dart';
import '../entities/reading_chapter.dart';

/// Chapters for the readers.
abstract class ReadingRepository {
  /// The downloaded copy when the chapter's download is done, online too;
  /// otherwise the server's. Throws `OfflineException` when the chapter is
  /// not downloaded and the server cannot be reached.
  Future<OpenedChapter> openChapter(ChapterId chapterId);

  /// [chapter] with the server's current previous and next chapters, for a
  /// downloaded copy. Server only: throws when it cannot be reached.
  Future<ReadingChapter> refreshNavigation(ReadingChapter chapter);

  /// Whether the chapter can be read from the device.
  Future<bool> isDownloaded(ChapterId chapterId);

  /// Marks [chapterId] as read on the server (`POST /chapters/:id/read`).
  Future<void> markChapterRead(ChapterId chapterId);

  /// Marks [chapterIds] as read on the server (`POST /chapters/batch/read`).
  Future<List<ChapterReadBatchResult>> markChaptersRead(
    List<ChapterId> chapterIds,
  );
}
