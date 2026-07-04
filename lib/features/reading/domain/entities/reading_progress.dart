import '../../../../shared/domain/value_objects/timestamp.dart';
import '../../../../features/books/domain/value_objects/book_id.dart';
import '../../../../features/books/domain/value_objects/chapter_id.dart';
import '../../../../shared/domain/value_objects/positive_int.dart';
import '../../../sync/domain/entities/syncable_entity.dart';

class ReadingProgress implements SyncableEntity {
  final ChapterId chapterId;
  final BookId bookId;
  final PositiveInt pageIndex;
  final Timestamp timestamp;
  final PositiveInt? totalPages;
  final bool completed;

  ReadingProgress({
    required this.chapterId,
    required this.bookId,
    required this.pageIndex,
    required this.timestamp,
    this.totalPages,
    required this.completed,
  });
}
