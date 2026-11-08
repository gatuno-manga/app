import 'package:equatable/equatable.dart';
import '../../../../core/base/base_stream_view_model.dart';
import '../../../../core/logging/logger.dart';
import '../../domain/use_cases/auth_service.dart';
import 'mfa_error.dart';

class MfaChallengeState extends Equatable {
  final bool isLoading;
  final MfaError? error;

  const MfaChallengeState({this.isLoading = false, this.error});

  @override
  List<Object?> get props => [isLoading, error];
}

/// Exchanges the sign-in challenge token plus a TOTP/backup code for a session.
class MfaChallengeViewModel extends BaseStreamViewModel<MfaChallengeState> {
  final AuthService _authService;
  final String _mfaToken;
  static const String _logTag = 'MfaChallengeViewModel';

  MfaChallengeViewModel(this._authService, this._mfaToken)
    : super(const MfaChallengeState());

  /// Returns true when the session was established.
  Future<bool> verify(String code) async {
    if (state.isLoading) return false;
    emit(const MfaChallengeState(isLoading: true));
    try {
      final ok = await _authService.verifyMfaLogin(_mfaToken, code.trim());
      emit(const MfaChallengeState());
      return ok;
    } catch (e) {
      AppLogger.w('MFA challenge failed: ${e.runtimeType}', _logTag);
      emit(MfaChallengeState(error: mfaErrorFrom(e)));
      return false;
    }
  }

  void clearError() => emit(const MfaChallengeState());
}
