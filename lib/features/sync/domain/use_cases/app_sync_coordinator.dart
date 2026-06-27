import 'dart:async';
import 'package:drift/drift.dart';
import '../../../../core/logging/logger.dart';
import '../../../authentication/domain/use_cases/auth_service.dart';
import '../../../reading/data/database/reading_database.dart';
import '../../../reading/data/models/reading_progress_dto.dart';
import '../../../reading/data/repositories/reading_progress_local_service.dart';
import '../../data/data_sources/sync_local_data_source.dart';
import '../../data/models/sync_dto.dart';
import '../../data/repositories/sync_remote_service.dart';
import '../../../../features/books/domain/value_objects/book_id.dart';
import '../../../../features/books/domain/value_objects/chapter_id.dart';
import '../../../../shared/domain/value_objects/positive_int.dart';
import '../../../../shared/domain/value_objects/timestamp.dart';
class AppSyncCoordinator {
  final SyncLocalDataSource _syncLocal;
  final SyncRemoteService _syncRemote;
  final AuthService _authService;
  final ReadingProgressLocalService _readingLocal;
  
  static const String _logTag = 'AppSyncCoordinator';
  bool _isSyncing = false;

  AppSyncCoordinator(
    this._syncLocal,
    this._syncRemote,
    this._authService,
    this._readingLocal,
  );

  Future<void> sync() async {
    if (_isSyncing) {
      AppLogger.d('Sync already in progress, skipping', _logTag);
      return;
    }

    final user = _authService.currentUser;
    if (user.isGuest) {
      AppLogger.d('Skipping sync for guest user', _logTag);
      return;
    }

    _isSyncing = true;
    try {
      AppLogger.i('Starting unified sync for user: ${user.id.value}', _logTag);
      
      final lastSyncAt = await _syncLocal.getLastSyncAt(user.id);

      // 1. Gather Reading Progress
      List<ReadingProgressData> localProgress;
      if (lastSyncAt != null) {
        localProgress = await _readingLocal.getModifiedSince(user.id, lastSyncAt.value);
      } else {
        localProgress = await _readingLocal.getAllProgress(user.id);
      }

      final progressDtos = localProgress.map((p) => SaveProgressDto(
        chapterId: ChapterId(p.chapterId),
        bookId: BookId(p.bookId),
        pageIndex: PositiveInt(p.pageIndex),
        timestamp: Timestamp(p.timestamp),
        totalPages: p.totalPages != null ? PositiveInt(p.totalPages!) : null,
        completed: p.completed,
      )).toList();

      // 2. Perform Push if there are local changes
      if (progressDtos.isNotEmpty) {
        AppLogger.d('Pushing ${progressDtos.length} reading progress items', _logTag);
        final pushRequest = PushSyncRequestDto(
          readingProgress: progressDtos,
        );
        await _syncRemote.pushData(pushRequest);
      }

      // 3. Perform Pull
      AppLogger.d('Pulling remote changes', _logTag);
      final pullResponse = await _syncRemote.pullData(lastSyncAt: lastSyncAt);

      // 4. Process Pull Result
      final readingProgressData = pullResponse.data['readingProgress'];
      if (readingProgressData != null && readingProgressData is List) {
        final syncedProgress = readingProgressData
            .map((e) => RemoteReadingProgress.fromJson(e as Map<String, dynamic>))
            .toList();

        for (final remote in syncedProgress) {
          await _readingLocal.saveProgress(
            ReadingProgressCompanion(
              userId: Value(remote.userId.value),
              chapterId: Value(remote.chapterId.value),
              bookId: Value(remote.bookId.value),
              pageIndex: Value(remote.pageIndex.value),
              timestamp: Value(remote.timestamp.value),
              version: Value(remote.version.value),
              totalPages: Value(remote.totalPages?.value),
              completed: Value(remote.completed ?? false),
            ),
          );
        }
      }

      // 5. Update lastSyncAt
      await _syncLocal.setLastSyncAt(user.id, pullResponse.syncedAt);
      AppLogger.i('Unified sync completed successfully', _logTag);
    } catch (e, stackTrace) {
      AppLogger.e('Error during unified sync', e, stackTrace, _logTag);
    } finally {
      _isSyncing = false;
    }
  }
}
