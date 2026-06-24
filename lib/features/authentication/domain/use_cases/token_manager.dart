import 'dart:async';
import '../../../../core/network/token_provider.dart';
import '../../../../core/logging/logger.dart';
import '../../../../core/utils/jwt_decoder.dart';
import '../repositories/auth_repository.dart';
import '../../data/data_sources/auth_local_data_source.dart';
import '../value_objects/auth_token.dart';

class TokenManager implements TokenProvider {
  final AuthRepository _authRepository;
  final AuthStorage _authStorage;
  static const String _logTag = 'TokenManager';

  Future<void>? _refreshFuture;
  Timer? _refreshTimer;
  bool _isPaused = false;

  String? _token;
  String? get currentToken => _token;

  Future<void> Function()? onRefreshFailed;
  void Function()? onTokenChanged;

  TokenManager(this._authRepository, this._authStorage);

  Future<void> initialize() async {
    _token = await _authStorage.getToken();
    if (_token != null) {
      scheduleRefresh();
    }
  }

  Future<void> saveToken(AuthToken token) async {
    _token = token.value;
    await _authStorage.saveToken(token.value);
    scheduleRefresh();
    onTokenChanged?.call();
  }

  Future<void> clearToken() async {
    _token = null;
    _refreshTimer?.cancel();
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
      await saveToken(response);
      AppLogger.i('Token refresh success', _logTag);
    } catch (e, stackTrace) {
      AppLogger.e('Token refresh failed', e, stackTrace, _logTag);
      if (onRefreshFailed != null) {
        await onRefreshFailed!();
      }
      rethrow;
    }
  }

  void scheduleRefresh() {
    _refreshTimer?.cancel();
    if (_token == null || _isPaused) return;

    final expiryDate = JwtDecoder.getExpirationDate(_token!);
    if (expiryDate == null) return;

    final now = DateTime.now();
    // Safety buffer: refresh 1 minute before expiry
    const buffer = Duration(minutes: 1);
    final timeUntilExpiry = expiryDate.difference(now);
    final delay = timeUntilExpiry - buffer;

    if (delay <= Duration.zero) {
      AppLogger.i(
        'Token expires soon or already expired, refreshing now',
        _logTag,
      );
      performTokenRefresh().catchError((Object e) {
        AppLogger.w('Scheduled refresh failed: $e', _logTag);
      });
    } else {
      AppLogger.d(
        'Scheduling proactive refresh in ${delay.inMinutes} minutes',
        _logTag,
      );
      _refreshTimer = Timer(delay, () {
        performTokenRefresh().catchError((Object e) {
          AppLogger.w('Scheduled refresh failed: $e', _logTag);
        });
      });
    }
  }

  void pauseRefresh() {
    if (!_isPaused) {
      AppLogger.d('Pausing proactive token refresh', _logTag);
      _isPaused = true;
      _refreshTimer?.cancel();
    }
  }

  void resumeRefresh() {
    if (_isPaused) {
      AppLogger.d('Resuming proactive token refresh', _logTag);
      _isPaused = false;
      scheduleRefresh();
    }
  }

  Future<void> evaluateTokenState() async {
    _isPaused = false;
    final token = await getToken();
    if (token != null &&
        JwtDecoder.isExpired(token, threshold: const Duration(minutes: 1))) {
      AppLogger.i(
        'Token expired or near expiry on wake-up, refreshing',
        _logTag,
      );
      try {
        await performTokenRefresh();
      } catch (e) {
        AppLogger.w('Refresh on wake-up failed: $e', _logTag);
      }
    } else {
      scheduleRefresh();
    }
  }
}
