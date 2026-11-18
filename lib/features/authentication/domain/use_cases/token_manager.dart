import 'dart:async';
import '../../../../core/network/exceptions.dart';
import '../../../../core/network/token_provider.dart';
import '../../../../core/logging/logger.dart';
import '../../../../core/utils/jwt_decoder.dart';
import '../repositories/auth_repository.dart';
import '../../data/data_sources/auth_local_data_source.dart';
import '../value_objects/auth_token.dart';

class TokenManager implements TokenProvider {
  final AuthRepository _authRepository;
  final AuthStorage _authStorage;
  final Future<void> Function(Duration) _delay;
  static const String _logTag = 'TokenManager';
  static const Duration _initialRetryBackoff = Duration(seconds: 30);
  static const Duration _maxRetryBackoff = Duration(minutes: 5);

  Future<void>? _refreshFuture;
  Timer? _refreshTimer;
  bool _isPaused = false;
  int _scheduledRefreshAttempt = 0;

  String? _token;
  String? get currentToken => _token;

  void Function()? onTokenChanged;

  TokenManager(
    this._authRepository,
    this._authStorage, {
    Future<void> Function(Duration)? delay,
  }) : _delay = delay ?? Future<void>.delayed;

  Future<void> initialize() async {
    _token = await _authStorage.getToken();
    if (_token != null) {
      scheduleRefresh();
    }
  }

  Future<void> saveToken(AuthToken token) async {
    _token = token.value;
    _scheduledRefreshAttempt = 0;
    await _authStorage.saveToken(token.value);
    scheduleRefresh();
    onTokenChanged?.call();
  }

  Future<void> clearToken() async {
    _token = null;
    _scheduledRefreshAttempt = 0;
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
      AuthToken response;
      try {
        response = await _authRepository.refreshToken();
      } on RefreshInProgressException catch (e) {
        AppLogger.i(
          'Token refresh locked (409), waiting ${e.retryAfter.inMilliseconds}ms before retrying once',
          _logTag,
        );
        await _delay(e.retryAfter);
        response = await _authRepository.refreshToken();
      }
      await saveToken(response);
      AppLogger.i('Token refresh success', _logTag);
    } catch (e, stackTrace) {
      AppLogger.e('Token refresh failed', e, stackTrace, _logTag);
      if (_isSessionDead(e)) {
        // Local only: /auth/logout needs a valid access token, and calling it
        // from here would wait on this very refresh (#159).
        final code = e is UnauthorizedException ? e.code : null;
        AppLogger.w(
          'Refresh refused${code != null ? ' ($code)' : ''}, signing out locally',
          _logTag,
        );
        await clearToken();
      }
      rethrow;
    }
  }

  /// Every 401 from `POST /auth/refresh` means the session is dead (with a
  /// `REFRESH_*` code), so sign out locally. `409 REFRESH_IN_PROGRESS` is
  /// retried once before failing; `403 CSRF_TOKEN_INVALID`, network errors,
  /// 429, and 5xx keep the token so the user stays signed in and the refresh
  /// can be retried later.
  bool _isSessionDead(Object error) {
    return error is UnauthorizedException;
  }

  Duration _nextRetryBackoff() {
    final shift = _scheduledRefreshAttempt.clamp(0, 4);
    final backoff = _initialRetryBackoff * (1 << shift);
    return backoff > _maxRetryBackoff ? _maxRetryBackoff : backoff;
  }

  Future<void> _runScheduledRefresh() async {
    try {
      await performTokenRefresh();
    } catch (e) {
      AppLogger.w('Scheduled refresh failed: $e', _logTag);
      if (_token != null && !_isPaused) {
        final backoff = _nextRetryBackoff();
        _scheduledRefreshAttempt++;
        AppLogger.d(
          'Rescheduling refresh in ${backoff.inSeconds}s '
          '(attempt $_scheduledRefreshAttempt)',
          _logTag,
        );
        _refreshTimer?.cancel();
        _refreshTimer = Timer(backoff, _runScheduledRefresh);
      }
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
      _runScheduledRefresh();
    } else {
      AppLogger.d(
        'Scheduling proactive refresh in ${delay.inMinutes} minutes',
        _logTag,
      );
      _refreshTimer = Timer(delay, _runScheduledRefresh);
    }
  }

  void pauseRefresh() {
    if (!_isPaused) {
      AppLogger.d('Pausing proactive token refresh', _logTag);
      _isPaused = true;
      _scheduledRefreshAttempt = 0;
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
