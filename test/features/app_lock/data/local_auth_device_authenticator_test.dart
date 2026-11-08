import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/app_lock/data/local_auth_device_authenticator.dart';
import 'package:gatuno/features/app_lock/domain/device_authenticator.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalAuthentication extends Mock implements LocalAuthentication {}

void main() {
  late MockLocalAuthentication localAuth;
  late LocalAuthDeviceAuthenticator authenticator;

  setUpAll(() => registerFallbackValue(<AuthMessages>[]));

  setUp(() {
    localAuth = MockLocalAuthentication();
    authenticator = LocalAuthDeviceAuthenticator(localAuth);
  });

  Future<DeviceAuthOutcome> authenticate({bool allowDeviceCredential = true}) =>
      authenticator.authenticate(
        messages: const DeviceAuthMessages(
          reason: 'Unlock',
          title: 'Locked',
          hint: 'Use a finger',
          cancel: 'Nope',
        ),
        allowDeviceCredential: allowDeviceCredential,
      );

  void stubAuthenticate({bool? result, LocalAuthException? error}) {
    final call = when(
      () => localAuth.authenticate(
        localizedReason: any(named: 'localizedReason'),
        biometricOnly: any(named: 'biometricOnly'),
        authMessages: any(named: 'authMessages'),
      ),
    );
    if (error != null) {
      call.thenThrow(error);
    } else {
      call.thenAnswer((_) async => result!);
    }
  }

  test('isDeviceSupported delegates to local_auth', () async {
    when(() => localAuth.isDeviceSupported()).thenAnswer((_) async => true);
    expect(await authenticator.isDeviceSupported(), isTrue);
  });

  test('success when the prompt returns true', () async {
    stubAuthenticate(result: true);
    expect(await authenticate(), DeviceAuthOutcome.success);
  });

  test('failed when the prompt returns false', () async {
    stubAuthenticate(result: false);
    expect(await authenticate(), DeviceAuthOutcome.failed);
  });

  test(
    'passes the reason and inverts the fallback flag into biometricOnly',
    () async {
      stubAuthenticate(result: true);
      await authenticate(allowDeviceCredential: false);
      verify(
        () => localAuth.authenticate(
          localizedReason: 'Unlock',
          biometricOnly: true,
          authMessages: any(named: 'authMessages'),
        ),
      ).called(1);
    },
  );

  test('translates the OS sheet on both platforms', () async {
    stubAuthenticate(result: true);
    await authenticate();
    final messages =
        verify(
              () => localAuth.authenticate(
                localizedReason: any(named: 'localizedReason'),
                biometricOnly: any(named: 'biometricOnly'),
                authMessages: captureAny(named: 'authMessages'),
              ),
            ).captured.single
            as List<AuthMessages>;

    final android = messages.whereType<AndroidAuthMessages>().single;
    expect(android.signInTitle, 'Locked');
    expect(android.signInHint, 'Use a finger');
    expect(android.cancelButton, 'Nope');
    final ios = messages.whereType<IOSAuthMessages>().single;
    expect(ios.cancelButton, 'Nope');
  });

  group('maps LocalAuthException codes', () {
    final cases = <LocalAuthExceptionCode, DeviceAuthOutcome>{
      LocalAuthExceptionCode.userCanceled: DeviceAuthOutcome.cancelled,
      LocalAuthExceptionCode.systemCanceled: DeviceAuthOutcome.cancelled,
      LocalAuthExceptionCode.timeout: DeviceAuthOutcome.cancelled,
      LocalAuthExceptionCode.temporaryLockout: DeviceAuthOutcome.lockedOut,
      LocalAuthExceptionCode.biometricLockout: DeviceAuthOutcome.lockedOut,
      LocalAuthExceptionCode.noCredentialsSet: DeviceAuthOutcome.noCredentials,
      LocalAuthExceptionCode.noBiometricsEnrolled:
          DeviceAuthOutcome.noBiometrics,
      LocalAuthExceptionCode.noBiometricHardware: DeviceAuthOutcome.unavailable,
      LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable:
          DeviceAuthOutcome.unavailable,
      LocalAuthExceptionCode.uiUnavailable: DeviceAuthOutcome.unavailable,
      LocalAuthExceptionCode.authInProgress: DeviceAuthOutcome.failed,
      LocalAuthExceptionCode.userRequestedFallback: DeviceAuthOutcome.failed,
      LocalAuthExceptionCode.deviceError: DeviceAuthOutcome.failed,
      LocalAuthExceptionCode.unknownError: DeviceAuthOutcome.failed,
    };

    for (final entry in cases.entries) {
      test('${entry.key.name} -> ${entry.value.name}', () async {
        stubAuthenticate(error: LocalAuthException(code: entry.key));
        expect(await authenticate(), entry.value);
      });
    }

    test('every code is covered by this table', () {
      expect(cases.keys.toSet(), LocalAuthExceptionCode.values.toSet());
    });
  });

  test('any other exception is reported as failed', () async {
    stubAuthenticate(error: null, result: null);
    when(
      () => localAuth.authenticate(
        localizedReason: any(named: 'localizedReason'),
        biometricOnly: any(named: 'biometricOnly'),
        authMessages: any(named: 'authMessages'),
      ),
    ).thenThrow(StateError('boom'));
    expect(await authenticate(), DeviceAuthOutcome.failed);
  });
}
