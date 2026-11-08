import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/value_objects/app_lock_grace.dart';

/// The lock flags are security-relevant, so they stay in secure storage.
class AppLockStorage {
  static const String _enabledKey = 'app_lock_enabled';
  static const String _graceKey = 'app_lock_grace_seconds';
  static const String _deviceCredentialKey = 'app_lock_device_credential';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<bool> isEnabled() async {
    return await _storage.read(key: _enabledKey) == 'true';
  }

  Future<void> setEnabled(bool enabled) async {
    await _storage.write(key: _enabledKey, value: enabled.toString());
  }

  Future<AppLockGrace> getGrace() async {
    final raw = await _storage.read(key: _graceKey);
    return AppLockGrace.fromSeconds(int.tryParse(raw ?? ''));
  }

  Future<void> setGrace(AppLockGrace grace) async {
    await _storage.write(
      key: _graceKey,
      value: grace.duration.inSeconds.toString(),
    );
  }

  Future<bool> isDeviceCredentialAllowed() async {
    return await _storage.read(key: _deviceCredentialKey) != 'false';
  }

  Future<void> setDeviceCredentialAllowed(bool allowed) async {
    await _storage.write(key: _deviceCredentialKey, value: allowed.toString());
  }
}
