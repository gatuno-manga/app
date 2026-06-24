import 'package:drift/drift.dart';
import '../database/reading_database.dart';
import '../../../../core/logging/logger.dart';

class ReadingProgressLocalService {
  final ReadingDatabase _database;
  static const String _logTag = 'ReadingProgressLocalService';

  ReadingProgressLocalService(this._database);

  Future<void> saveProgress(ReadingProgressCompanion progress) async {
    AppLogger.d(
      'Saving progress locally for chapter: ${progress.chapterId.value}',
      _logTag,
    );
    try {
      await _database
          .into(_database.readingProgress)
          .insertOnConflictUpdate(progress);
    } catch (e, stackTrace) {
      AppLogger.e('Error saving progress locally', e, stackTrace, _logTag);
      rethrow;
    }
  }

  Future<ReadingProgressData?> getProgress(
    String userId,
    String chapterId,
  ) async {
    try {
      return await (_database.select(_database.readingProgress)..where(
            (t) => t.userId.equals(userId) & t.chapterId.equals(chapterId),
          ))
          .getSingleOrNull();
    } catch (e, stackTrace) {
      AppLogger.e('Error getting progress locally', e, stackTrace, _logTag);
      rethrow;
    }
  }

  Future<List<ReadingProgressData>> getAllProgressForBook(
    String userId,
    String bookId,
  ) async {
    try {
      return await (_database.select(
        _database.readingProgress,
      )..where((t) => t.userId.equals(userId) & t.bookId.equals(bookId))).get();
    } catch (e, stackTrace) {
      AppLogger.e(
        'Error getting all progress for book locally',
        e,
        stackTrace,
        _logTag,
      );
      rethrow;
    }
  }

  Future<ReadingProgressData?> getLastReadChapter(
    String userId,
    String bookId,
  ) async {
    AppLogger.d(
      'Querying last read chapter: userId=$userId, bookId=$bookId',
      _logTag,
    );
    try {
      final result =
          await (_database.select(_database.readingProgress)
                ..where(
                  (t) => t.userId.equals(userId) & t.bookId.equals(bookId),
                )
                ..orderBy([
                  (t) => OrderingTerm(
                    expression: t.timestamp,
                    mode: OrderingMode.desc,
                  ),
                ])
                ..limit(1))
              .getSingleOrNull();

      AppLogger.d(
        'Last read chapter query result: ${result?.chapterId}',
        _logTag,
      );
      return result;
    } catch (e, stackTrace) {
      AppLogger.e(
        'Error getting last read progress locally',
        e,
        stackTrace,
        _logTag,
      );
      rethrow;
    }
  }

  Future<List<ReadingProgressData>> getAllGuestProgress() async {
    try {
      return await (_database.select(
        _database.readingProgress,
      )..where((t) => t.userId.equals('guest'))).get();
    } catch (e, stackTrace) {
      AppLogger.e(
        'Error getting guest progress locally',
        e,
        stackTrace,
        _logTag,
      );
      rethrow;
    }
  }

  Future<void> updateProgressUserId(String oldUserId, String newUserId) async {
    AppLogger.i('Migrating progress from $oldUserId to $newUserId', _logTag);
    try {
      await _database.transaction(() async {
        final items = await (_database.select(_database.readingProgress)
              ..where((t) => t.userId.equals(oldUserId)))
            .get();

        for (final item in items) {
          await _database
              .into(_database.readingProgress)
              .insertOnConflictUpdate(
                ReadingProgressCompanion(
                  userId: Value(newUserId),
                  chapterId: Value(item.chapterId),
                  bookId: Value(item.bookId),
                  pageIndex: Value(item.pageIndex),
                  timestamp: Value(item.timestamp),
                  version: Value(item.version),
                  totalPages: Value(item.totalPages),
                  completed: Value(item.completed),
                ),
              );
        }

        await (_database.delete(_database.readingProgress)
              ..where((t) => t.userId.equals(oldUserId)))
            .go();
      });
    } catch (e, stackTrace) {
      AppLogger.e('Error migrating progress userId', e, stackTrace, _logTag);
      rethrow;
    }
  }

  Future<List<String>> getRecentUniqueBookIds(String userId, {int limit = 10}) async {
    try {
      final query = _database.selectOnly(_database.readingProgress)
        ..addColumns([_database.readingProgress.bookId, _database.readingProgress.timestamp.max()])
        ..where(_database.readingProgress.userId.equals(userId))
        ..groupBy([_database.readingProgress.bookId])
        ..orderBy([
          OrderingTerm(
            expression: _database.readingProgress.timestamp.max(),
            mode: OrderingMode.desc,
          ),
        ])
        ..limit(limit);

      final result = await query.get();
      return result
          .map((row) => row.read(_database.readingProgress.bookId)!)
          .toList();
    } catch (e, stackTrace) {
      AppLogger.e('Error getting recent unique book ids', e, stackTrace, _logTag);
      rethrow;
    }
  }

  Future<void> deleteSyncedProgress(String userId) async {
    // This could be used for cleanup, but for now we keep everything locally as per offline-first
  }
}
