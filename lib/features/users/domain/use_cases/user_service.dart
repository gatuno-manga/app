import 'dart:async';
import 'dart:typed_data';

import 'package:rxdart/rxdart.dart';

import '../../../../core/utils/jwt_decoder.dart';
import '../../../authentication/domain/use_cases/auth_service.dart';
import '../../data/data_sources/user_local_data_source.dart';
import '../../data/data_sources/user_remote_data_source.dart';
import '../../data/models/user_model.dart';
import '../../../../core/logging/logger.dart';
import '../value_objects/profile_image_failure.dart';
import '../value_objects/profile_image_kind.dart';

class UserService {
  final AuthService _authService;
  final UserRemoteDataSource _remote;
  final UserStorage _storage;
  static const String _logTag = 'UserService';

  final BehaviorSubject<UserModel> _profileSubject = BehaviorSubject.seeded(
    UserModel.guest,
  );
  StreamSubscription<AuthState>? _authSubscription;

  /// Bumped on every sign-out; see [_unlessSignedOut].
  int _sessionEpoch = 0;

  /// The current profile, replayed to new listeners: guest until sign-in,
  /// then the cached `/me` user, then every refresh or upload.
  Stream<UserModel> get profileStream => _profileSubject.stream;

  UserService(
    this._authService, {
    required UserRemoteDataSource remote,
    required UserStorage storage,
  }) : _remote = remote,
       _storage = storage;

  /// Starts following auth state. Called from `initDI` once the Dio
  /// interceptors are installed, so the sign-in `/me` fetch carries the
  /// token; registration alone must not resolve AuthService.
  void init() {
    _authSubscription ??= _authService.authStateStream.distinct().listen(
      _onAuthChanged,
    );
  }

  /// One `/me` fetch per sign-in keeps every avatar current without any
  /// screen having to ask; the cached user shows first and a failed fetch
  /// keeps it.
  Future<void> _onAuthChanged(AuthState authState) async {
    switch (authState) {
      case AuthState.authenticated:
        final user = await _unlessSignedOut(getCurrentUser);
        if (user == null) return;
        _profileSubject.add(user);
        await refreshProfile();
      case AuthState.unauthenticated:
        _endSession();
      case AuthState.uninitialized:
        break;
    }
  }

  void _endSession() {
    _sessionEpoch++;
    _profileSubject.add(UserModel.guest);
  }

  /// Runs [request]; null when a sign-out happened while it was in flight,
  /// so a result for the previous session is never published.
  Future<T?> _unlessSignedOut<T extends Object>(
    Future<T> Function() request,
  ) async {
    final epoch = _sessionEpoch;
    final result = await request();
    if (epoch == _sessionEpoch) return result;
    AppLogger.i('Dropping a result that resolved after sign-out', _logTag);
    return null;
  }

  /// Fetches a profile with [request], caches it and publishes it; null when
  /// a sign-out happened while the request or the cache write was in flight.
  /// The publish is synchronous after the last check, so nothing for the
  /// previous session reaches the stream.
  Future<UserModel?> _commitProfile(
    Future<Map<String, dynamic>> Function() request,
  ) async {
    final profile = await _unlessSignedOut(request);
    if (profile == null) return null;
    final user = await _unlessSignedOut(() async {
      await _storage.writeProfile(profile);
      return UserModel.fromJson(profile);
    });
    if (user == null) {
      // The write landed after logout cleared the cache: wipe it again.
      await _storage.clear();
      return null;
    }
    _profileSubject.add(user);
    return user;
  }

  /// The signed-in user from the JWT, enriched with the cached `/me` profile
  /// (image URLs) when it belongs to the same account.
  Future<UserModel> getCurrentUser() async {
    try {
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) {
        await _storage.clear();
        return UserModel.guest;
      }

      if (JwtDecoder.isExpired(token)) {
        AppLogger.w('Access token expired while getting current user', _logTag);
        return UserModel.guest;
      }

      final payload = JwtDecoder.decode(token);
      final jwtUser = UserModel.fromJwt(payload);
      return await _cachedProfileFor(jwtUser) ?? jwtUser;
    } catch (e, stackTrace) {
      AppLogger.e(
        'Error getting current user from JWT',
        e,
        stackTrace,
        _logTag,
      );
      return UserModel.guest;
    }
  }

  Future<UserModel?> _cachedProfileFor(UserModel jwtUser) async {
    final cached = await _storage.readProfile();
    if (cached == null) return null;
    try {
      final profile = UserModel.fromJson(cached);
      return profile.id == jwtUser.id ? profile : null;
    } catch (e) {
      AppLogger.w('Ignoring malformed cached profile: $e', _logTag);
      return null;
    }
  }

  /// Fetches `/me`, caches it and returns it; null when offline or failing,
  /// or when the account signed out while the request was in flight.
  Future<UserModel?> refreshProfile() async {
    try {
      return await _commitProfile(_remote.fetchMe);
    } catch (e) {
      AppLogger.w('Could not refresh profile: $e', _logTag);
      return null;
    }
  }

  /// Validates and uploads a profile image, returning the updated user.
  /// Throws [ProfileImageFailure] on rejection; the old image stays.
  Future<UserModel> uploadProfileImage({
    required ProfileImageKind kind,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final invalid = validateProfileImage(
      kind: kind,
      fileName: fileName,
      sizeBytes: bytes.length,
    );
    if (invalid != null) throw invalid;
    final UserModel? user;
    try {
      user = await _commitProfile(
        () => _remote.uploadImage(kind: kind, bytes: bytes, fileName: fileName),
      );
    } on ProfileImageFailure {
      rethrow;
    } catch (e) {
      throw ProfileImageFailure(ProfileImageFailureReason.unknown, kind);
    }
    if (user == null) {
      throw ProfileImageFailure(ProfileImageFailureReason.signedOut, kind);
    }
    return user;
  }

  Future<void> logout() async {
    await _storage.clear();
    // Drop the avatar now; AuthService only reports the sign-out after the
    // backend round-trip.
    _endSession();
    await _authService.logout();
  }

  void dispose() {
    _authSubscription?.cancel();
    _profileSubject.close();
  }
}
