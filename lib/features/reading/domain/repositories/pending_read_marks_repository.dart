import '../../../books/domain/value_objects/chapter_id.dart';
import '../../../users/domain/value_objects/user_id.dart';

/// Persistent offline queue of chapter-read marks awaiting server sync.
abstract class PendingReadMarksRepository {
  Future<void> enqueue(UserId userId, ChapterId chapterId);
  Future<List<ChapterId>> getPendingChapterIds(UserId userId);
  Future<void> remove(UserId userId, List<ChapterId> chapterIds);
}
