import '../../../../core/base/base_stream_view_model.dart';
import '../../domain/use_cases/auth_service.dart';
import '../../domain/value_objects/email_address.dart';
import '../../domain/value_objects/password.dart';
import '../../../../core/logging/logger.dart';
import 'package:equatable/equatable.dart';

class SignUpState extends Equatable {
  final bool isLoading;
  final String? errorMessage;

  const SignUpState({
    required this.isLoading,
    this.errorMessage,
  });

  factory SignUpState.initial() {
    return const SignUpState(
      isLoading: false,
      errorMessage: null,
    );
  }

  SignUpState copyWith({
    bool? isLoading,
    String? Function()? errorMessage,
  }) {
    return SignUpState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage];
}

class SignUpViewModel extends BaseStreamViewModel<SignUpState> {
  final AuthService _authService;
  static const String _logTag = 'SignUpViewModel';

  SignUpViewModel(this._authService) : super(SignUpState.initial());

  Future<bool> signUp(String email, String password) async {
    final redactedEmail = AppLogger.redactEmail(email);
    AppLogger.i('SignUp requested for: $redactedEmail', _logTag);
    emit(state.copyWith(isLoading: true, errorMessage: () => null));

    try {
      final success = await _authService.signUp(EmailAddress(email), Password(password));
      AppLogger.i('SignUp result for $redactedEmail: $success', _logTag);
      emit(state.copyWith(isLoading: false));
      return success;
    } catch (e, stackTrace) {
      AppLogger.e(
        'SignUp error for $redactedEmail: ${e.toString()}',
        e,
        stackTrace,
        _logTag,
      );
      emit(state.copyWith(isLoading: false, errorMessage: () => e.toString()));
      return false;
    }
  }

  void clearError() {
    AppLogger.d('Clearing SignUp error', _logTag);
    emit(state.copyWith(errorMessage: () => null));
  }
}
