import 'package:equatable/equatable.dart';

/// Result of asking the OS to verify the device owner.
enum DeviceAuthOutcome {
  success,

  /// The user or the system dismissed the prompt before a decision.
  cancelled,

  /// Too many failed attempts; biometrics are refused until the OS lifts it.
  lockedOut,

  /// No screen lock at all: nothing to authenticate with.
  noCredentials,

  /// Biometrics were required (fallback off) but none is enrolled.
  noBiometrics,

  /// Hardware missing or temporarily unavailable.
  unavailable,

  /// The prompt ran and rejected the user, or an unexpected error occurred.
  failed,
}

/// Translated strings for the OS sheet; which ones each platform shows
/// is up to its adapter.
class DeviceAuthMessages extends Equatable {
  final String reason;
  final String title;
  final String hint;
  final String cancel;

  const DeviceAuthMessages({
    required this.reason,
    required this.title,
    required this.hint,
    required this.cancel,
  });

  @override
  List<Object?> get props => [reason, title, hint, cancel];
}

/// Port over the platform's local authentication (biometrics, device PIN).
abstract class DeviceAuthenticator {
  /// Whether the device has any secure credential the lock can rely on.
  Future<bool> isDeviceSupported();

  /// Shows the OS prompt. With [allowDeviceCredential] the OS may fall back
  /// to PIN/pattern/passcode.
  Future<DeviceAuthOutcome> authenticate({
    required DeviceAuthMessages messages,
    required bool allowDeviceCredential,
  });
}
