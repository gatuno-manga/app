import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../features/users/domain/value_objects/user_id.dart';
import '../../../../shared/domain/value_objects/timestamp.dart';

class SyncLocalDataSource {
  static const String _lastSyncAtKeyPrefix = 'last_sync_at_';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> setLastSyncAt(UserId userId, Timestamp timestamp) async {
    await _storage.write(key: '$_lastSyncAtKeyPrefix${userId.value}', value: timestamp.value.toIso8601String());
  }

  Future<Timestamp?> getLastSyncAt(UserId userId) async {
    final str = await _storage.read(key: '$_lastSyncAtKeyPrefix${userId.value}');
    return str != null ? Timestamp.fromJson(str) : null;
  }

  Future<void> clearLastSyncAt(UserId userId) async {
    await _storage.delete(key: '$_lastSyncAtKeyPrefix${userId.value}');
  }
}
