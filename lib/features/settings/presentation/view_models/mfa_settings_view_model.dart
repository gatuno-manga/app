import 'package:equatable/equatable.dart';
import '../../../../core/base/base_stream_view_model.dart';
import '../../../../core/logging/logger.dart';
import '../../../../core/network/exceptions.dart';
import '../../../authentication/domain/repositories/mfa_repository.dart';
import '../../../authentication/domain/value_objects/mfa_models.dart';
import '../../../authentication/presentation/view_models/mfa_error.dart';

enum MfaPhase { loading, loadFailed, status, setup, backupCodes }

class MfaSettingsState extends Equatable {
  final MfaPhase phase;
  final MfaStatus? status;
  final TotpSetup? setup;
  final List<String> backupCodes;
  final bool isBusy;
  final MfaError? error;

  const MfaSettingsState({
    this.phase = MfaPhase.loading,
    this.status,
    this.setup,
    this.backupCodes = const [],
    this.isBusy = false,
    this.error,
  });

  MfaSettingsState copyWith({
    MfaPhase? phase,
    MfaStatus? status,
    TotpSetup? Function()? setup,
    List<String>? backupCodes,
    bool? isBusy,
    MfaError? Function()? error,
  }) => MfaSettingsState(
    phase: phase ?? this.phase,
    status: status ?? this.status,
    setup: setup != null ? setup() : this.setup,
    backupCodes: backupCodes ?? this.backupCodes,
    isBusy: isBusy ?? this.isBusy,
    error: error != null ? error() : this.error,
  );

  @override
  List<Object?> get props => [phase, status, setup, backupCodes, isBusy, error];
}

class MfaSettingsViewModel extends BaseStreamViewModel<MfaSettingsState> {
  final MfaRepository _repository;
  static const String _logTag = 'MfaSettingsViewModel';

  MfaSettingsViewModel(this._repository) : super(const MfaSettingsState());

  Future<void> load() async {
    emit(const MfaSettingsState());
    try {
      final status = await _repository.status();
      emit(MfaSettingsState(phase: MfaPhase.status, status: status));
    } catch (e) {
      AppLogger.w('MFA status load failed: ${e.runtimeType}', _logTag);
      // A 401 here means the session is gone, not that a code was wrong.
      final error = e is UnauthorizedException
          ? MfaError.unknown
          : mfaErrorFrom(e);
      emit(MfaSettingsState(phase: MfaPhase.loadFailed, error: error));
    }
  }

  /// Fetches a fresh TOTP secret. When MFA is already enabled this replaces the
  /// existing authenticator and backup codes (the caller must confirm first).
  Future<void> startSetup() async {
    emit(state.copyWith(isBusy: true, error: () => null));
    try {
      final setup = await _repository.setupTotp();
      emit(
        state.copyWith(
          phase: MfaPhase.setup,
          setup: () => setup,
          isBusy: false,
        ),
      );
    } catch (e) {
      AppLogger.w('MFA setup failed: ${e.runtimeType}', _logTag);
      emit(state.copyWith(isBusy: false, error: () => mfaErrorFrom(e)));
    }
  }

  Future<void> confirmSetup(String code) async {
    emit(state.copyWith(isBusy: true, error: () => null));
    try {
      final result = await _repository.verifyTotpSetup(code.trim());
      emit(
        state.copyWith(
          phase: MfaPhase.backupCodes,
          backupCodes: result.codes,
          setup: () => null,
          isBusy: false,
        ),
      );
    } catch (e) {
      AppLogger.w('MFA setup verification failed: ${e.runtimeType}', _logTag);
      emit(state.copyWith(isBusy: false, error: () => mfaErrorFrom(e)));
    }
  }

  void cancelSetup() => emit(
    state.copyWith(
      phase: MfaPhase.status,
      setup: () => null,
      error: () => null,
    ),
  );

  /// Drops the plaintext codes from memory and returns to the status view.
  Future<void> acknowledgeBackupCodes() async {
    emit(state.copyWith(backupCodes: const []));
    await load();
  }

  Future<bool> disable(String code) async {
    emit(state.copyWith(isBusy: true, error: () => null));
    try {
      await _repository.disableTotp(code.trim());
      await load();
      return true;
    } catch (e) {
      AppLogger.w('MFA disable failed: ${e.runtimeType}', _logTag);
      emit(state.copyWith(isBusy: false, error: () => mfaErrorFrom(e)));
      return false;
    }
  }

  void clearError() => emit(state.copyWith(error: () => null));
}
