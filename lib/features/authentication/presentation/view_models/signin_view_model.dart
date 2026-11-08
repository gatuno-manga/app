import '../../../../core/base/base_stream_view_model.dart';
import '../../../../core/network/exceptions.dart';
import '../../domain/use_cases/auth_service.dart';
import '../../domain/value_objects/email_address.dart';
import '../../domain/value_objects/password.dart';
import '../../../../core/logging/logger.dart';
import 'package:equatable/equatable.dart';

class SignInState extends Equatable {
  final bool isLoading;
  final String? errorMessage;

  /// Set when the backend requires an MFA step-up before issuing a session.
  final String? mfaToken;

  const SignInState({
    required this.isLoading,
    this.errorMessage,
    this.mfaToken,
  });

  factory SignInState.initial() {
    return const SignInState(isLoading: false, errorMessage: null);
  }

  SignInState copyWith({
    bool? isLoading,
    String? Function()? errorMessage,
    String? Function()? mfaToken,
  }) {
    return SignInState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      mfaToken: mfaToken != null ? mfaToken() : this.mfaToken,
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, mfaToken];
}

class SignInViewModel extends BaseStreamViewModel<SignInState> {
  final AuthService _authService;
  static const String _logTag = 'SignInViewModel';

  SignInViewModel(this._authService) : super(SignInState.initial());

  Future<bool> signIn(String email, String password) async {
    final redactedEmail = AppLogger.redactEmail(email);
    AppLogger.i('SignIn requested for: $redactedEmail', _logTag);
    emit(state.copyWith(isLoading: true, errorMessage: () => null));

    try {
      final success = await _authService.signIn(
        EmailAddress(email),
        Password(password),
      );
      AppLogger.i('SignIn result for $redactedEmail: $success', _logTag);
      emit(state.copyWith(isLoading: false));
      return success;
    } on MfaRequiredException catch (e) {
      AppLogger.i('MFA challenge required for: $redactedEmail', _logTag);
      emit(state.copyWith(isLoading: false, mfaToken: () => e.mfaToken));
      return false;
    } catch (e, stackTrace) {
      AppLogger.e(
        'SignIn error for $redactedEmail: ${e.toString()}',
        e,
        stackTrace,
        _logTag,
      );
      emit(state.copyWith(isLoading: false, errorMessage: () => e.toString()));
      return false;
    }
  }

  void clearMfaChallenge() => emit(state.copyWith(mfaToken: () => null));

  void clearError() {
    AppLogger.d('Clearing SignIn error', _logTag);
    emit(state.copyWith(errorMessage: () => null));
  }
}
