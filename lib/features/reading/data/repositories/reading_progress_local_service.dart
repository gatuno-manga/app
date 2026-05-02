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
      await _database.into(_database.readingProgress).insertOnConflictUpdate(progress);
    } catch (e, stackTrace) {
      AppLogger.e('Error saving progress locally', e, stackTrace, _logTag);
      rethrow;
    }
  }

  Future<ReadingProgressData?> getProgress(String userId, String chapterId) async {
    try {
      return await (_database.select(_database.readingProgress)
            ..where((t) => t.userId.equals(userId) & t.chapterId.equals(chapterId)))
          .getSingleOrNull();
    } catch (e, stackTrace) {
      AppLogger.e('Error getting progress locally', e, stackTrace, _logTag);
      rethrow;
    }
  }

  Future<List<ReadingProgressData>> getAllGuestProgress() async {
    try {
      return await (_database.select(_database.readingProgress)
            ..where((t) => t.userId.equals('guest')))
          .get();
    } catch (e, stackTrace) {
      AppLogger.e('Error getting guest progress locally', e, stackTrace, _logTag);
      rethrow;
    }
  }

  Future<void> updateProgressUserId(String oldUserId, String newUserId) async {
    AppLogger.i('Migrating progress from $oldUserId to $newUserId', _logTag);
    try {
      await (_database.update(_database.readingProgress)
            ..where((t) => t.userId.equals(oldUserId)))
          .write(ReadingProgressCompanion(userId: Value(newUserId)));
    } catch (e, stackTrace) {
      AppLogger.e('Error migrating progress userId', e, stackTrace, _logTag);
      rethrow;
    }
  }

  Future<void> deleteSyncedProgress(String userId) async {
    // This could be used for cleanup, but for now we keep everything locally as per offline-first
  }
}
