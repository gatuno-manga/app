import 'package:shared_preferences/shared_preferences.dart';

import '../../../../features/users/domain/value_objects/user_id.dart';
import '../../../../shared/domain/value_objects/timestamp.dart';

/// The last sync time is not sensitive, so it lives in shared_preferences.
class SyncLocalDataSource {
  static const String _lastSyncAtKeyPrefix = 'last_sync_at_';

  String _key(UserId userId) => '$_lastSyncAtKeyPrefix${userId.value}';

  Future<void> setLastSyncAt(UserId userId, Timestamp timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(userId), timestamp.value.toIso8601String());
  }

  Future<Timestamp?> getLastSyncAt(UserId userId) async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_key(userId));
    return str != null ? Timestamp.fromJson(str) : null;
  }

  Future<void> clearLastSyncAt(UserId userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(userId));
  }
}
