import 'dart:async';
import 'package:flutter/widgets.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/logging/logger.dart';
import '../../../../core/utils/jwt_decoder.dart';
import '../../../users/data/models/user_model.dart';
import '../value_objects/email_address.dart';
import '../value_objects/password.dart';
import 'package:rxdart/rxdart.dart';
import 'token_manager.dart';

enum AuthState { uninitialized, unauthenticated, authenticated }

class AuthService with WidgetsBindingObserver {
  final AuthRepository _authRepository;
  final TokenManager _tokenManager;
  static const String _logTag = 'AuthService';

  final _authStateSubject = BehaviorSubject<AuthState>.seeded(AuthState.uninitialized);
  Stream<AuthState> get authStateStream => _authStateSubject.stream;
  AuthState get authState => _authStateSubject.value;

  AuthService(this._authRepository, this._tokenManager) {
    _tokenManager.onRefreshFailed = () async {
      await logout();
    };
    _tokenManager.onTokenChanged = () {
      _updateAuthState();
    };
    WidgetsBinding.instance.addObserver(this);
    _initAuth();
  }

  void dispose() {
    _authStateSubject.close();
    WidgetsBinding.instance.removeObserver(this);
  }

  void _updateAuthState() {
    final token = _tokenManager.currentToken;
    final isAuth = token != null && token.isNotEmpty && !JwtDecoder.isExpired(token);
    _authStateSubject.add(isAuth ? AuthState.authenticated : AuthState.unauthenticated);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _tokenManager.pauseRefresh();
    } else if (state == AppLifecycleState.resumed) {
      _tokenManager.evaluateTokenState();
    }
  }

  bool get isInitialized => authState != AuthState.uninitialized;
  bool get authenticated => authState == AuthState.authenticated;

  UserModel get currentUser {
    final token = _tokenManager.currentToken;
    if (token == null || token.isEmpty) return UserModel.guest;
    try {
      if (JwtDecoder.isExpired(token)) return UserModel.guest;
      final payload = JwtDecoder.decode(token);
      return UserModel.fromJwt(payload);
    } catch (e) {
      return UserModel.guest;
    }
  }

  Future<void> _initAuth() async {
    await _tokenManager.initialize();
    final token = _tokenManager.currentToken;
    if (token != null && token.isNotEmpty) {
      if (JwtDecoder.isExpired(token)) {
        AppLogger.i('Stored token is expired, attempting refresh', _logTag);
        try {
          await _tokenManager.performTokenRefresh();
        } catch (e) {
          AppLogger.w('Initial token refresh failed: $e', _logTag);
        }
      }
      _authStateSubject.add(_tokenManager.currentToken != null ? AuthState.authenticated : AuthState.unauthenticated);
    } else {
      _authStateSubject.add(AuthState.unauthenticated);
    }
    AppLogger.d(
      'AuthService initialized: authenticated = ${authState == AuthState.authenticated}',
      _logTag,
    );
  }

  Future<bool> signIn(EmailAddress email, Password password) async {
    final redactedEmail = AppLogger.redactEmail(email.value);
    AppLogger.i('Performing signIn for: $redactedEmail', _logTag);
    try {
      final response = await _authRepository.signIn(email, password);

      await _tokenManager.saveToken(response);

      AppLogger.i(
        'SignIn completed and token saved for: $redactedEmail',
        _logTag,
      );
      _authStateSubject.add(AuthState.authenticated);
      return true;
    } catch (e, stackTrace) {
      AppLogger.e(
        'SignIn failed in AuthService for: $redactedEmail',
        e,
        stackTrace,
        _logTag,
      );
      rethrow;
    }
  }

  Future<bool> signUp(EmailAddress email, Password password) async {
    final redactedEmail = AppLogger.redactEmail(email.value);
    AppLogger.i('Performing signUp for: $redactedEmail', _logTag);
    try {
      await _authRepository.signUp(email, password);
      AppLogger.i(
        'SignUp success, performing auto-signIn for: $redactedEmail',
        _logTag,
      );
      // Auto-signIn after successful signup
      return signIn(email, password);
    } catch (e, stackTrace) {
      AppLogger.e(
        'SignUp failed in AuthService for: $redactedEmail',
        e,
        stackTrace,
        _logTag,
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    AppLogger.i('Performing logout', _logTag);
    try {
      // Call backend logout
      await _authRepository.logout();
    } catch (e) {
      // We log but still clear tokens locally
      AppLogger.w(
        'Backend logout failed, clearing local tokens anyway: $e',
        _logTag,
      );
    }
    await _tokenManager.clearToken();
    _authStateSubject.add(AuthState.unauthenticated);
    AppLogger.i('Tokens cleared successfully', _logTag);
  }

  Future<String?> getToken() async {
    return _tokenManager.getToken();
  }

  Future<bool> isAuthenticated() async {
    final token = await _tokenManager.getToken();
    bool authenticated = token != null && token.isNotEmpty;

    if (authenticated && JwtDecoder.isExpired(token)) {
      AppLogger.i('Token expired in isAuthenticated check', _logTag);
      try {
        await _tokenManager.performTokenRefresh();
        authenticated = _tokenManager.currentToken != null;
      } catch (e) {
        authenticated = false;
      }
    }

    if (authenticated != (authState == AuthState.authenticated)) {
      _authStateSubject.add(authenticated ? AuthState.authenticated : AuthState.unauthenticated);
    }

    return authenticated;
  }

  Future<void> performTokenRefresh() async {
    await _tokenManager.performTokenRefresh();
  }

  void pauseRefresh() {
    _tokenManager.pauseRefresh();
  }

  void evaluateTokenState() {
    _tokenManager.evaluateTokenState();
  }
}
