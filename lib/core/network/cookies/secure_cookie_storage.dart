import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../storage/background_readable_storage.dart';

/// A secure implementation of [Storage] for [PersistCookieJar].
/// Uses [FlutterSecureStorage] to persist cookies securely, readable while
/// the device is locked: the refresh token cookie keeps the background
/// new-chapter check signed in.
class SecureCookieStorage implements Storage {
  static const String _prefix = 'cookie_';

  final BackgroundReadableStorage _store;

  SecureCookieStorage({BackgroundReadableStorage? store})
    : _store =
          store ??
          BackgroundReadableStorage(owns: (k) => k.startsWith(_prefix));

  FlutterSecureStorage get _secureStorage => _store.storage;

  @override
  Future<void> init(bool persistSession, bool ignoreExpires) =>
      _store.migrate();

  @override
  Future<String?> read(String key) async {
    await _store.migrate();
    return await _secureStorage.read(key: '$_prefix$key');
  }

  @override
  Future<void> write(String key, String value) async {
    await _store.migrate();
    await _secureStorage.write(key: '$_prefix$key', value: value);
  }

  @override
  Future<void> delete(String key) async {
    await _store.migrate();
    await _secureStorage.delete(key: '$_prefix$key');
  }

  @override
  Future<void> deleteAll(List<String> keys) async {
    await _store.migrate();
    for (final key in keys) {
      await _secureStorage.delete(key: '$_prefix$key');
    }
  }
}
