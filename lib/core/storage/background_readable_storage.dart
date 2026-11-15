import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../logging/logger.dart';

/// Secure storage that background work can read while the device is locked.
///
/// On iOS the keychain items use `first_unlock`: readable once the device was
/// unlocked after a reboot, so the background new-chapter check can use the
/// session at night. Items written before used the default `unlocked`, which
/// [migrate] moves over. Android encrypts with a Keystore key that needs no
/// user authentication, so nothing changes there.
class BackgroundReadableStorage {
  static const String _logTag = 'BackgroundReadableStorage';

  static const IOSOptions iOSOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  final FlutterSecureStorage storage;
  final FlutterSecureStorage _legacy;
  final bool _isIOS;
  final bool Function(String key) _owns;
  Future<void>? _migrated;

  /// [owns] picks the keys of this store among the app's keychain items.
  BackgroundReadableStorage({
    required bool Function(String key) owns,
    FlutterSecureStorage? storage,
    FlutterSecureStorage? legacy,
    bool? isIOS,
  }) : storage = storage ?? const FlutterSecureStorage(iOptions: iOSOptions),
       _legacy = legacy ?? const FlutterSecureStorage(),
       _isIOS = isIOS ?? Platform.isIOS,
       _owns = owns;

  /// Moves this store's items written with the default accessibility to
  /// `first_unlock`, once. Run it before any read or write. A failure (the
  /// device locked during the first run after an update) is logged and tried
  /// again on the next call.
  Future<void> migrate() =>
      _migrated ??= _migrate().catchError((Object e, StackTrace stackTrace) {
        _migrated = null;
        AppLogger.e('Keychain migration failed', e, stackTrace, _logTag);
      });

  Future<void> _migrate() async {
    if (!_isIOS) return;
    // Matches only items with the default accessibility.
    final old = await _legacy.readAll();
    for (final MapEntry(:key, :value) in old.entries) {
      if (!_owns(key)) continue;
      // The keychain keeps one item per key whatever its accessibility, so
      // the old one goes first.
      await _legacy.delete(key: key);
      await storage.write(key: key, value: value);
    }
  }
}
