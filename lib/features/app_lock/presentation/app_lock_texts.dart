import 'package:gatuno/l10n/app_localizations.dart';

import '../domain/device_authenticator.dart';
import '../domain/value_objects/app_lock_grace.dart';

/// User-facing reason the last prompt did not succeed; null when it did.
String? appLockOutcomeText(AppLocalizations l10n, DeviceAuthOutcome? outcome) {
  switch (outcome) {
    case null:
    case DeviceAuthOutcome.success:
      return null;
    case DeviceAuthOutcome.cancelled:
      return l10n.appLockErrorCancelled;
    case DeviceAuthOutcome.lockedOut:
      return l10n.appLockErrorLockedOut;
    case DeviceAuthOutcome.noCredentials:
      return l10n.appLockErrorNoCredentials;
    case DeviceAuthOutcome.noBiometrics:
      return l10n.appLockErrorNoBiometrics;
    case DeviceAuthOutcome.noBiometricHardware:
      return l10n.appLockErrorNoBiometricHardware;
    case DeviceAuthOutcome.unavailable:
      return l10n.appLockErrorUnavailable;
    case DeviceAuthOutcome.failed:
      return l10n.appLockErrorFailed;
  }
}

/// The OS sheet strings for one prompt; only the reason and title differ
/// between callers. The hint mentions the PIN only when it is an option.
DeviceAuthMessages appLockPromptMessages(
  AppLocalizations l10n, {
  required String reason,
  required String title,
  required bool allowDeviceCredential,
}) => DeviceAuthMessages(
  reason: reason,
  title: title,
  hint: allowDeviceCredential
      ? l10n.appLockPromptHintWithCredential
      : l10n.appLockPromptHint,
  cancel: l10n.commonCancel,
);

String appLockGraceLabel(AppLocalizations l10n, AppLockGrace grace) {
  switch (grace) {
    case AppLockGrace.immediately:
      return l10n.appLockGraceImmediately;
    case AppLockGrace.thirtySeconds:
      return l10n.appLockGraceThirtySeconds;
    case AppLockGrace.oneMinute:
      return l10n.appLockGraceOneMinute;
    case AppLockGrace.fiveMinutes:
      return l10n.appLockGraceFiveMinutes;
    case AppLockGrace.fifteenMinutes:
      return l10n.appLockGraceFifteenMinutes;
  }
}
