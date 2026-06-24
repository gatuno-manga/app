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
      
      final lastSyncAtStr = await _syncLocal.getLastSyncAt(user.id.value);
      final lastSyncAt = lastSyncAtStr != null ? DateTime.parse(lastSyncAtStr) : null;

      // 1. Gather Reading Progress
      List<ReadingProgressData> localProgress;
      if (lastSyncAt != null) {
        localProgress = await _readingLocal.getModifiedSince(user.id.value, lastSyncAt);
      } else {
        localProgress = await _readingLocal.getAllProgress(user.id.value);
      }

      final progressDtos = localProgress.map((p) => SaveProgressDto(
        chapterId: p.chapterId,
        bookId: p.bookId,
        pageIndex: p.pageIndex,
        timestamp: p.timestamp.millisecondsSinceEpoch,
        totalPages: p.totalPages,
        completed: p.completed,
      )).toList();

      final request = SyncRequestDto(
        lastSyncAt: lastSyncAt?.toIso8601String(),
        readingProgress: progressDtos.isNotEmpty ? progressDtos : null,
      );

      // 2. Perform Sync
      final result = await _syncRemote.syncData(request);

      // 3. Process Result
      if (result.readingProgress != null) {
        final syncedProgress = result.readingProgress!.synced;
        for (final remote in syncedProgress) {
          await _readingLocal.saveProgress(
            ReadingProgressCompanion(
              userId: Value(remote.userId),
              chapterId: Value(remote.chapterId),
              bookId: Value(remote.bookId),
              pageIndex: Value(remote.pageIndex),
              timestamp: Value(remote.timestamp),
              version: Value(remote.version),
              totalPages: Value(remote.totalPages),
              completed: Value(remote.completed ?? false),
            ),
          );
        }
      }

      // 4. Update lastSyncAt
      await _syncLocal.setLastSyncAt(user.id.value, result.syncedAt);
      AppLogger.i('Unified sync completed successfully', _logTag);
    } catch (e, stackTrace) {
      AppLogger.e('Error during unified sync', e, stackTrace, _logTag);
    } finally {
      _isSyncing = false;
    }
  }
}
