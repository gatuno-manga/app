import '../../../../features/users/domain/value_objects/user_id.dart';
import '../entities/syncable_entity.dart';
import '../value_objects/sync_feature_key.dart';

abstract class LocalSyncFeatureProvider<T extends SyncableEntity> {
  SyncFeatureKey get syncKey;

  Future<void> processPulledData(List<dynamic> remoteData, UserId currentUserId);

  Future<List<T>> getLocalChanges(UserId currentUserId, DateTime? lastSyncAt);
}
