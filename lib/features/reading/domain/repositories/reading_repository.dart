import '../../../books/domain/value_objects/chapter_id.dart';
import '../entities/reading_chapter.dart';

abstract class ReadingRepository {
  Future<ReadingChapter> getChapter(ChapterId chapterId);
}
