import '../../../books/domain/value_objects/chapter_id.dart';
import '../entities/downloaded_chapter.dart';

/// Read side of downloads, for the readers.
abstract class DownloadedContent {
  /// The stored chapter, or `null` unless its download is done.
  Future<DownloadedChapter?> chapter(ChapterId chapterId);
}
