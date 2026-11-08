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

  final BehaviorSubject<UserModel?> _profileSubject = BehaviorSubject();
  late final StreamSubscription<AuthState> _authSubscription;

  /// The cached `/me` profile whenever it changes: after a refresh or an
  /// upload, and null once the account signs out. Replays the last value.
  Stream<UserModel?> get profileStream => _profileSubject.stream;

  UserService(
    this._authService, {
    required UserRemoteDataSource remote,
    required UserStorage storage,
  }) : _remote = remote,
       _storage = storage {
    _authSubscription = _authService.authStateStream.listen(_onAuthChanged);
  }

  /// One `/me` fetch per sign-in keeps every avatar current without any
  /// screen having to ask; a failed fetch keeps the cache.
  void _onAuthChanged(AuthState authState) {
    switch (authState) {
      case AuthState.authenticated:
        refreshProfile();
      case AuthState.unauthenticated:
        _profileSubject.add(null);
      case AuthState.uninitialized:
        break;
    }
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

  /// Fetches `/me`, caches it and returns it; null when offline or failing.
  Future<UserModel?> refreshProfile() async {
    try {
      return await _storeProfile(await _remote.fetchMe());
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
    final profile = await _remote.uploadImage(
      kind: kind,
      bytes: bytes,
      fileName: fileName,
    );
    try {
      return await _storeProfile(profile);
    } catch (e) {
      throw ProfileImageFailure(ProfileImageFailureReason.unknown, kind);
    }
  }

  Future<UserModel> _storeProfile(Map<String, dynamic> profile) async {
    final user = UserModel.fromJson(profile);
    await _storage.writeProfile(profile);
    _profileSubject.add(user);
    return user;
  }

  Future<void> logout() async {
    await _storage.clear();
    _profileSubject.add(null);
    await _authService.logout();
  }

  void dispose() {
    _authSubscription.cancel();
    _profileSubject.close();
  }
}
