import 'dart:async';
import '../../../../core/logging/logger.dart';
import '../../../authentication/domain/use_cases/auth_service.dart';
import '../../data/data_sources/sync_local_data_source.dart';
import '../repositories/sync_repository.dart';
import '../entities/syncable_entity.dart';
import '../value_objects/sync_feature_key.dart';
import 'local_sync_feature_provider.dart';

class AppSyncCoordinator {
  final SyncLocalDataSource _syncLocal;
  final SyncRepository _syncRepository;
  final AuthService _authService;
  final List<LocalSyncFeatureProvider> _providers;

  static const String _logTag = 'AppSyncCoordinator';
  bool _isSyncing = false;

  AppSyncCoordinator(
    this._syncLocal,
    this._syncRepository,
    this._authService,
    this._providers,
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

      // 1. Perform Pull
      AppLogger.d('Pulling remote changes', _logTag);
      final pullResponse = await _syncRepository.pullData(
        lastSyncAt: lastSyncAt,
      );

      // 2. Process Pull Result using providers
      for (final provider in _providers) {
        final data = pullResponse.data[provider.syncKey.key];
        if (data != null && data is List) {
          await provider.processPulledData(data, user.id);
        }
      }

      // 3. Gather Local Progress
      final Map<SyncFeatureKey, List<SyncableEntity>> pushPayload = {};

      for (final provider in _providers) {
        final changes = await provider.getLocalChanges(
          user.id,
          lastSyncAt?.value,
        );
        if (changes.isNotEmpty) {
          pushPayload[provider.syncKey] = changes;
        }
      }

      // 4. Perform Push if there are local changes
      if (pushPayload.isNotEmpty) {
        AppLogger.d('Pushing local changes to remote', _logTag);
        await _syncRepository.pushData(pushPayload);
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
