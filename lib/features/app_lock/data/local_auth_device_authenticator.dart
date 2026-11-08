import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

import '../../../core/logging/logger.dart';
import '../domain/device_authenticator.dart';

class LocalAuthDeviceAuthenticator implements DeviceAuthenticator {
  static const String _logTag = 'LocalAuthDeviceAuthenticator';

  final LocalAuthentication _localAuth;

  LocalAuthDeviceAuthenticator(this._localAuth);

  @override
  Future<bool> isDeviceSupported() => _localAuth.isDeviceSupported();

  @override
  Future<DeviceAuthOutcome> authenticate({
    required DeviceAuthMessages messages,
    required bool allowDeviceCredential,
  }) async {
    try {
      final ok = await _localAuth.authenticate(
        localizedReason: messages.reason,
        biometricOnly: !allowDeviceCredential,
        // The plugin's own defaults are English only.
        authMessages: [
          AndroidAuthMessages(
            signInTitle: messages.title,
            signInHint: messages.hint,
            cancelButton: messages.cancel,
          ),
          IOSAuthMessages(cancelButton: messages.cancel),
        ],
      );
      return ok ? DeviceAuthOutcome.success : DeviceAuthOutcome.failed;
    } on LocalAuthException catch (e) {
      AppLogger.w('Device authentication ended with ${e.code.name}', _logTag);
      return _outcomeFor(e.code);
    } catch (e, stackTrace) {
      AppLogger.e('Device authentication crashed', e, stackTrace, _logTag);
      return DeviceAuthOutcome.failed;
    }
  }

  static DeviceAuthOutcome _outcomeFor(LocalAuthExceptionCode code) {
    switch (code) {
      case LocalAuthExceptionCode.userCanceled:
      case LocalAuthExceptionCode.systemCanceled:
      case LocalAuthExceptionCode.timeout:
        return DeviceAuthOutcome.cancelled;
      case LocalAuthExceptionCode.temporaryLockout:
      case LocalAuthExceptionCode.biometricLockout:
        return DeviceAuthOutcome.lockedOut;
      case LocalAuthExceptionCode.noCredentialsSet:
        return DeviceAuthOutcome.noCredentials;
      case LocalAuthExceptionCode.noBiometricsEnrolled:
        return DeviceAuthOutcome.noBiometrics;
      case LocalAuthExceptionCode.noBiometricHardware:
      case LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable:
      case LocalAuthExceptionCode.uiUnavailable:
        return DeviceAuthOutcome.unavailable;
      case LocalAuthExceptionCode.authInProgress:
      case LocalAuthExceptionCode.userRequestedFallback:
      case LocalAuthExceptionCode.deviceError:
      case LocalAuthExceptionCode.unknownError:
        return DeviceAuthOutcome.failed;
    }
  }
}
