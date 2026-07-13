import '../../../../core/base/base_stream_view_model.dart';
import '../../domain/use_cases/user_service.dart';
import '../../data/models/user_model.dart';
import '../../../../core/logging/logger.dart';
import 'package:equatable/equatable.dart';

class MeState extends Equatable {
  final UserModel user;
  final bool isLoading;

  const MeState({
    required this.user,
    required this.isLoading,
  });

  factory MeState.initial() {
    return MeState(
      user: UserModel.guest,
      isLoading: true,
    );
  }

  MeState copyWith({
    UserModel? user,
    bool? isLoading,
  }) {
    return MeState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [user, isLoading];
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
      AppLogger.i(
        'MeViewModel initialized: user=${user.displayName}',
        _logTag,
      );
      emit(state.copyWith(user: user, isLoading: false));
    } catch (e, stackTrace) {
      AppLogger.e('Error initializing MeViewModel', e, stackTrace, _logTag);
      emit(state.copyWith(user: UserModel.guest, isLoading: false));
    }
  }

  Future<void> logout() async {
    AppLogger.i('User requested logout from MeViewModel', _logTag);
    await _userService.logout();
  }
}
