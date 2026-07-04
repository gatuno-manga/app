import 'package:drift/drift.dart';
import '../../../../core/logging/logger.dart';
import '../../../../features/users/domain/value_objects/user_id.dart';
import '../../../../features/sync/domain/use_cases/local_sync_feature_provider.dart';
import '../../../../features/sync/domain/value_objects/sync_feature_key.dart';
import '../../../../shared/domain/value_objects/timestamp.dart';
import '../../../../features/books/domain/value_objects/book_id.dart';
import '../../../../features/books/domain/value_objects/chapter_id.dart';
import '../../../../shared/domain/value_objects/positive_int.dart';
import '../../domain/entities/reading_progress.dart';
import '../models/reading_progress_dto.dart';
import 'reading_progress_local_service.dart';
import '../database/reading_database.dart' show ReadingProgressCompanion, ReadingProgressData;

class ReadingProgressSyncProviderImpl implements LocalSyncFeatureProvider<ReadingProgress> {
  final ReadingProgressLocalService _readingLocal;
  static const String _logTag = 'ReadingProgressSyncProvider';

  ReadingProgressSyncProviderImpl(this._readingLocal);

  @override
  SyncFeatureKey get syncKey => SyncFeatureKey.readingProgress;

  @override
  Future<void> processPulledData(List<dynamic> remoteData, UserId currentUserId) async {
    final syncedProgress = remoteData
        .map((e) => RemoteReadingProgress.fromJson(e as Map<String, dynamic>))
        .toList();

    for (final remote in syncedProgress) {
      final effectiveUserId = remote.userId ?? currentUserId;
      final current = await _readingLocal.getProgress(effectiveUserId, remote.chapterId);
      final remoteTime = remote.updatedAt ?? remote.timestamp ?? Timestamp(DateTime.now());
      
      bool shouldUpdateLocal = false;
      if (current == null) {
        shouldUpdateLocal = true;
      } else if (remoteTime.value.isAfter(current.timestamp)) {
        shouldUpdateLocal = true;
      }

      if (shouldUpdateLocal) {
        await _readingLocal.saveProgress(
          ReadingProgressCompanion(
            userId: Value(effectiveUserId.value),
            chapterId: Value(remote.chapterId.value),
            bookId: Value(remote.bookId.value),
            pageIndex: Value(remote.pageIndex.value),
            timestamp: Value(remoteTime.value),
            totalPages: Value(remote.totalPages?.value),
            completed: Value(remote.completed ?? false),
          ),
        );
        AppLogger.d('Local progress updated from sync pull payload', _logTag);
      }
    }
  }

  @override
  Future<List<ReadingProgress>> getLocalChanges(UserId currentUserId, DateTime? lastSyncAt) async {
    List<ReadingProgressData> localProgress;
    if (lastSyncAt != null) {
      localProgress = await _readingLocal.getModifiedSince(currentUserId, lastSyncAt);
    } else {
      localProgress = await _readingLocal.getAllProgress(currentUserId);
    }

    return localProgress.map((p) => ReadingProgress(
      chapterId: ChapterId(p.chapterId),
      bookId: BookId(p.bookId),
      pageIndex: PositiveInt(p.pageIndex),
      timestamp: Timestamp(p.timestamp),
      totalPages: p.totalPages != null ? PositiveInt(p.totalPages!) : null,
      completed: p.completed,
    )).toList();
  }
}
