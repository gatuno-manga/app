import '../entities/reading_chapter.dart';

abstract class ReadingRepository {
  Future<ReadingChapter> getChapter(String chapterId);
}
