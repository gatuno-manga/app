import '../../../../shared/domain/value_objects/timestamp.dart';

class PullSyncResponse {
  final Timestamp syncedAt;
  final Map<String, dynamic> data;

  PullSyncResponse({
    required this.syncedAt,
    required this.data,
  });
}
