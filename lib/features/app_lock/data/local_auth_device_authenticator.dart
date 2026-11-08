import 'package:local_auth/local_auth.dart';

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
    required String reason,
    required bool allowDeviceCredential,
  }) async {
    try {
      final ok = await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: !allowDeviceCredential,
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
      case LocalAuthExceptionCode.noBiometricsEnrolled:
        return DeviceAuthOutcome.noCredentials;
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
