import 'dart:async';
import '../../../../core/network/token_provider.dart';
import '../../../../core/logging/logger.dart';
import '../../../../core/utils/jwt_decoder.dart';
import '../repositories/auth_repository.dart';
import '../../data/data_sources/auth_local_data_source.dart';

class TokenManager implements TokenProvider {
  final AuthRepository _authRepository;
  final AuthStorage _authStorage;
  static const String _logTag = 'TokenManager';

  Future<void>? _refreshFuture;

  String? _token;
  String? get currentToken => _token;

  Future<void> Function()? onRefreshFailed;
  void Function()? onTokenChanged;

  TokenManager(this._authRepository, this._authStorage);

  Future<void> initialize() async {
    _token = await _authStorage.getToken();
  }

  Future<void> saveToken(String token) async {
    _token = token;
    await _authStorage.saveToken(token);
    onTokenChanged?.call();
  }

  Future<void> clearToken() async {
    _token = null;
    await _authStorage.clearToken();
    onTokenChanged?.call();
  }

  Future<String?> getToken() async {
    _token ??= await _authStorage.getToken();
    return _token;
  }

  @override
  Future<String?> getValidToken({bool forceRefresh = false}) async {
    String? token = await getToken();
    if (token == null || token.isEmpty) return null;

    if (forceRefresh || JwtDecoder.isExpired(token)) {
      AppLogger.i(
        'Token is expired or force refresh requested, waiting for refresh',
        _logTag,
      );
      try {
        await performTokenRefresh();
        return currentToken;
      } catch (e) {
        AppLogger.w('Token refresh failed during getValidToken: $e', _logTag);
        return null;
      }
    } else if (JwtDecoder.isExpired(
      token,
      threshold: const Duration(minutes: 2),
    )) {
      AppLogger.i(
        'Token near expiry, triggering eager refresh in background',
        _logTag,
      );
      // Fire and forget
      performTokenRefresh().catchError((Object e) {
        AppLogger.w('Background token refresh failed: $e', _logTag);
      });
    }

    return token;
  }

  @override
  Future<void> performTokenRefresh() async {
    if (_refreshFuture != null) {
      AppLogger.d(
        'Refresh already in progress, waiting for existing future',
        _logTag,
      );
      return _refreshFuture;
    }

    _refreshFuture = _performTokenRefreshInternal();
    try {
      await _refreshFuture;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<void> _performTokenRefreshInternal() async {
    AppLogger.i('Performing token refresh', _logTag);
    try {
      final response = await _authRepository.refreshToken();
      await saveToken(response.token);
      AppLogger.i('Token refresh success', _logTag);
    } catch (e, stackTrace) {
      AppLogger.e('Token refresh failed', e, stackTrace, _logTag);
      if (onRefreshFailed != null) {
        await onRefreshFailed!();
      }
      rethrow;
    }
  }
}
