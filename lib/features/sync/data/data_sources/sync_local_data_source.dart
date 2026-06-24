import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SyncLocalDataSource {
  static const String _lastSyncAtKeyPrefix = 'last_sync_at_';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> setLastSyncAt(String userId, String isoString) async {
    await _storage.write(key: '$_lastSyncAtKeyPrefix$userId', value: isoString);
  }

  Future<String?> getLastSyncAt(String userId) async {
    return await _storage.read(key: '$_lastSyncAtKeyPrefix$userId');
  }

  Future<void> clearLastSyncAt(String userId) async {
    await _storage.delete(key: '$_lastSyncAtKeyPrefix$userId');
  }
}
