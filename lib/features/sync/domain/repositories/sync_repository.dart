import '../entities/pull_sync_response.dart';
import '../entities/syncable_entity.dart';
import '../value_objects/sync_feature_key.dart';
import '../../../../shared/domain/value_objects/timestamp.dart';

abstract class SyncRepository {
  Future<PullSyncResponse> pullData({Timestamp? lastSyncAt});
  
  Future<void> pushData(Map<SyncFeatureKey, List<SyncableEntity>> payload);
}
