import 'package:drift/drift.dart';

import '../../../../core/logging/logger.dart';
import '../../../../features/books/domain/value_objects/chapter_id.dart';
import '../../../../features/users/domain/value_objects/user_id.dart';
import '../../domain/repositories/pending_read_marks_repository.dart';
import '../database/reading_database.dart';

/// Persists chapter-read marks that could not be sent to the server yet.
class PendingReadMarksLocalService implements PendingReadMarksRepository {
  final ReadingDatabase _database;
  static const String _logTag = 'PendingReadMarksLocalService';

  PendingReadMarksLocalService(this._database);

  @override
  Future<void> enqueue(UserId userId, ChapterId chapterId) async {
    AppLogger.d(
      'Queueing offline read mark: userId=${userId.value}, chapterId=${chapterId.value}',
      _logTag,
    );
    await _database
        .into(_database.pendingReadMarks)
        .insertOnConflictUpdate(
          PendingReadMarksCompanion.insert(
            userId: userId.value,
            chapterId: chapterId.value,
            createdAt: DateTime.now(),
          ),
        );
  }

  @override
  Future<List<ChapterId>> getPendingChapterIds(UserId userId) async {
    final rows =
        await (_database.select(_database.pendingReadMarks)
              ..where((t) => t.userId.equals(userId.value))
              ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
            .get();
    return [for (final row in rows) ChapterId(row.chapterId)];
  }

  @override
  Future<void> remove(UserId userId, List<ChapterId> chapterIds) async {
    if (chapterIds.isEmpty) return;
    final ids = chapterIds.map((id) => id.value).toList();
    await (_database.delete(_database.pendingReadMarks)
          ..where((t) => t.userId.equals(userId.value) & t.chapterId.isIn(ids)))
        .go();
  }
}
