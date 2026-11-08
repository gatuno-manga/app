/// Result of asking the OS to verify the device owner.
enum DeviceAuthOutcome {
  success,

  /// The user or the system dismissed the prompt before a decision.
  cancelled,

  /// Too many failed attempts; biometrics are refused until the OS lifts it.
  lockedOut,

  /// Nothing to authenticate with: no biometric enrolled and, when the
  /// device credential fallback is off, nothing else to fall back to.
  noCredentials,

  /// Hardware missing or temporarily unavailable.
  unavailable,

  /// The prompt ran and rejected the user, or an unexpected error occurred.
  failed,
}

/// Port over the platform's local authentication (biometrics, device PIN).
abstract class DeviceAuthenticator {
  /// Whether the device has any secure credential the lock can rely on.
  Future<bool> isDeviceSupported();

  /// Shows the OS prompt. [reason] is the user-facing message in the prompt.
  /// With [allowDeviceCredential] the OS may fall back to PIN/pattern/passcode.
  Future<DeviceAuthOutcome> authenticate({
    required String reason,
    required bool allowDeviceCredential,
  });
}
