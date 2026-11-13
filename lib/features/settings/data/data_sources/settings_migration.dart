import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/logging/logger.dart';

/// Moves the non-sensitive values that used to live in secure storage into
/// shared_preferences, so existing users keep their settings (#79).
///
/// Order per key is copy, delete, and the done flag last, so a crash at any
/// point leaves the value in at least one store and the next launch retries.
class SettingsMigration {
  static const String _logTag = 'SettingsMigration';

  /// Set once every key has been moved.
  static const String doneKey = 'secure_to_prefs_migrated_v1';

  static const String _apiUrlKey = 'api_base_url';
  static const String _sensitiveContentKey = 'sensitive_content_enabled';
  static const String _lastSyncAtPrefix = 'last_sync_at_';

  final FlutterSecureStorage _secure;

  SettingsMigration({FlutterSecureStorage? secure})
    : _secure = secure ?? const FlutterSecureStorage();

  /// Never throws: a failure is logged and retried on the next launch, and
  /// must not stop the app from starting.
  Future<void> run() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(doneKey) ?? false) return;

      final all = await _secure.readAll();
      // Snapshot: deleting while iterating the store's own map would throw.
      for (final entry in all.entries.toList()) {
        final key = entry.key;
        if (key == _sensitiveContentKey) {
          await _move(prefs, key, () async {
            await prefs.setBool(key, entry.value == 'true');
          });
        } else if (key == _apiUrlKey || key.startsWith(_lastSyncAtPrefix)) {
          await _move(prefs, key, () async {
            await prefs.setString(key, entry.value);
          });
        }
      }

      await prefs.setBool(doneKey, true);
      AppLogger.i('Migrated settings to shared_preferences', _logTag);
    } catch (e, s) {
      AppLogger.e('Settings migration failed, will retry', e, s, _logTag);
    }
  }

  /// Prefs wins when both stores hold a value: it is the newer write.
  Future<void> _move(
    SharedPreferences prefs,
    String key,
    Future<void> Function() copy,
  ) async {
    if (!prefs.containsKey(key)) await copy();
    await _secure.delete(key: key);
  }
}
