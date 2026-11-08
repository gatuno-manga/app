import 'dart:typed_data';
import '../../../../core/base/base_stream_view_model.dart';
import '../../domain/use_cases/user_service.dart';
import '../../data/models/user_model.dart';
import '../../../../core/logging/logger.dart';
import 'package:equatable/equatable.dart';
import '../../domain/value_objects/profile_image_failure.dart';
import '../../domain/value_objects/profile_image_kind.dart';

class MeState extends Equatable {
  final UserModel user;
  final bool isLoading;
  final Set<ProfileImageKind> uploading;

  const MeState({
    required this.user,
    required this.isLoading,
    this.uploading = const {},
  });

  factory MeState.initial() {
    return MeState(user: UserModel.guest, isLoading: true);
  }

  MeState copyWith({
    UserModel? user,
    bool? isLoading,
    Set<ProfileImageKind>? uploading,
  }) {
    return MeState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      uploading: uploading ?? this.uploading,
    );
  }

  @override
  List<Object?> get props => [user, isLoading, uploading];
}

class MeViewModel extends BaseStreamViewModel<MeState> {
  final UserService _userService;
  static const String _logTag = 'MeViewModel';

  MeViewModel(this._userService) : super(MeState.initial());

  Future<void> init() async {
    AppLogger.i('Initializing MeViewModel', _logTag);
    emit(state.copyWith(isLoading: true));

    try {
      final user = await _userService.getCurrentUser();
      AppLogger.i('MeViewModel initialized: user=${user.displayName}', _logTag);
      emit(state.copyWith(user: user, isLoading: false));
      await _refreshProfile(user);
    } catch (e, stackTrace) {
      AppLogger.e('Error initializing MeViewModel', e, stackTrace, _logTag);
      emit(state.copyWith(user: UserModel.guest, isLoading: false));
    }
  }

  Future<void> _refreshProfile(UserModel current) async {
    if (current.isGuest) return;
    final fresh = await _userService.refreshProfile();
    if (fresh != null) emit(state.copyWith(user: fresh));
  }

  /// Uploads a picked image. Returns the failure to show, or null on success.
  Future<ProfileImageFailure?> uploadImage({
    required ProfileImageKind kind,
    required String fileName,
    required Uint8List bytes,
  }) async {
    if (state.uploading.contains(kind)) return null;
    emit(state.copyWith(uploading: {...state.uploading, kind}));
    try {
      final user = await _userService.uploadProfileImage(
        kind: kind,
        fileName: fileName,
        bytes: bytes,
      );
      emit(state.copyWith(user: user, uploading: _without(kind)));
      return null;
    } on ProfileImageFailure catch (failure) {
      emit(state.copyWith(uploading: _without(kind)));
      // Nothing to tell a user who just signed out.
      if (failure.reason == ProfileImageFailureReason.signedOut) return null;
      return failure;
    } catch (e, stackTrace) {
      AppLogger.e('Unexpected upload error', e, stackTrace, _logTag);
      emit(state.copyWith(uploading: _without(kind)));
      return ProfileImageFailure(ProfileImageFailureReason.unknown, kind);
    }
  }

  Set<ProfileImageKind> _without(ProfileImageKind kind) =>
      state.uploading.difference({kind});

  Future<void> logout() async {
    AppLogger.i('User requested logout from MeViewModel', _logTag);
    await _userService.logout();
  }
}
