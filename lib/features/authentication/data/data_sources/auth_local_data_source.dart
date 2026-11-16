import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/storage/background_readable_storage.dart';

class AuthStorage {
  static const String _tokenKey = 'access_token';

  /// Readable while the device is locked, for the background new-chapter
  /// check.
  final BackgroundReadableStorage _store;

  AuthStorage({BackgroundReadableStorage? store})
    : _store = store ?? BackgroundReadableStorage(owns: (k) => k == _tokenKey);

  FlutterSecureStorage get _storage => _store.storage;

  Future<void> saveToken(String token) async {
    await _store.migrate();
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    await _store.migrate();
    return await _storage.read(key: _tokenKey);
  }

  Future<void> clearToken() async {
    await _store.migrate();
    await _storage.delete(key: _tokenKey);
  }

  // Legacy support for clearTokens if needed by other parts of the app,
  // but following the plan we rename it.
  Future<void> clearTokens() => clearToken();
}
