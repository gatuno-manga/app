import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/app_lock/data/data_sources/app_lock_local_data_source.dart';
import 'package:gatuno/features/app_lock/domain/device_authenticator.dart';
import 'package:gatuno/features/app_lock/domain/privacy_screen.dart';
import 'package:gatuno/features/app_lock/domain/use_cases/app_lock_service.dart';
import 'package:gatuno/features/app_lock/domain/value_objects/app_lock_grace.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/app_lock_mocks.dart';

class MockAppLockStorage extends Mock implements AppLockStorage {}

class MockDeviceAuthenticator extends Mock implements DeviceAuthenticator {}

class MockPrivacyScreen extends Mock implements PrivacyScreen {}

void main() {
  late MockAppLockStorage storage;
  late MockDeviceAuthenticator authenticator;
  late MockPrivacyScreen privacyScreen;
  late DateTime now;
  late AppLockService service;

  setUpAll(() {
    registerFallbackValue(AppLockGrace.oneMinute);
    registerFallbackValue(testMessages);
  });

  setUp(() {
    storage = MockAppLockStorage();
    authenticator = MockDeviceAuthenticator();
    privacyScreen = MockPrivacyScreen();
    now = DateTime(2026, 11, 7, 12);

    when(() => storage.isEnabled()).thenAnswer((_) async => false);
    when(
      () => storage.getGrace(),
    ).thenAnswer((_) async => AppLockGrace.oneMinute);
    when(
      () => storage.isDeviceCredentialAllowed(),
    ).thenAnswer((_) async => true);
    when(() => storage.setEnabled(any())).thenAnswer((_) async {});
    when(() => storage.setGrace(any())).thenAnswer((_) async {});
    when(
      () => storage.setDeviceCredentialAllowed(any()),
    ).thenAnswer((_) async {});
    when(() => authenticator.isDeviceSupported()).thenAnswer((_) async => true);
    when(() => privacyScreen.setEnabled(any())).thenAnswer((_) async {});

    service = AppLockService(
      storage: storage,
      authenticator: authenticator,
      privacyScreen: privacyScreen,
      clock: () => now,
    );
  });

  tearDown(() => service.dispose());

  void stubPrompt(DeviceAuthOutcome outcome) {
    when(
      () => authenticator.authenticate(
        messages: any(named: 'messages'),
        allowDeviceCredential: any(named: 'allowDeviceCredential'),
      ),
    ).thenAnswer((_) async => outcome);
  }

  Future<void> initEnabled({
    AppLockGrace grace = AppLockGrace.oneMinute,
  }) async {
    when(() => storage.isEnabled()).thenAnswer((_) async => true);
    when(() => storage.getGrace()).thenAnswer((_) async => grace);
    await service.init();
  }

  group('init', () {
    test('loads persisted flags and device support', () async {
      when(() => storage.isEnabled()).thenAnswer((_) async => true);
      when(
        () => storage.getGrace(),
      ).thenAnswer((_) async => AppLockGrace.fiveMinutes);
      when(
        () => storage.isDeviceCredentialAllowed(),
      ).thenAnswer((_) async => false);

      await service.init();

      expect(service.state.isInitialized, isTrue);
      expect(service.state.isSupported, isTrue);
      expect(service.state.enabled, isTrue);
      expect(service.state.grace, AppLockGrace.fiveMinutes);
      expect(service.state.deviceCredentialAllowed, isFalse);
    });

    test('starts locked when the lock is enabled', () async {
      await initEnabled();
      expect(service.state.locked, isTrue);
    });

    test('starts unlocked when the lock is disabled', () async {
      await service.init();
      expect(service.state.locked, isFalse);
    });

    test('turns the privacy screen off when the lock is disabled', () async {
      await service.init();
      verify(() => privacyScreen.setEnabled(false)).called(1);
      verifyNever(() => privacyScreen.setEnabled(true));
    });

    test('turns the privacy screen on when the lock is enabled', () async {
      await initEnabled();
      verify(() => privacyScreen.setEnabled(true)).called(1);
      verifyNever(() => privacyScreen.setEnabled(false));
    });

    test('reports an unsupported device', () async {
      when(
        () => authenticator.isDeviceSupported(),
      ).thenAnswer((_) async => false);
      await service.init();
      expect(service.state.isSupported, isFalse);
    });

    test('still starts locked when the support probe throws', () async {
      when(() => storage.isEnabled()).thenAnswer((_) async => true);
      when(
        () => authenticator.isDeviceSupported(),
      ).thenThrow(Exception('plugin'));

      await service.init();

      expect(service.state.isInitialized, isTrue);
      expect(service.state.isSupported, isFalse);
      expect(service.state.enabled, isTrue);
      expect(service.state.locked, isTrue);
    });

    test('survives a storage failure and stays unlocked', () async {
      when(() => storage.isEnabled()).thenThrow(Exception('storage'));
      await service.init();
      expect(service.state.isInitialized, isTrue);
      expect(service.state.enabled, isFalse);
      expect(service.state.locked, isFalse);
    });
  });

  group('setEnabled', () {
    test('enabling runs the prompt and persists on success', () async {
      await service.init();
      stubPrompt(DeviceAuthOutcome.success);

      final outcome = await service.setEnabled(true, messages: testMessages);

      expect(outcome, DeviceAuthOutcome.success);
      expect(service.state.enabled, isTrue);
      expect(service.state.locked, isFalse);
      verify(() => storage.setEnabled(true)).called(1);
      verify(() => privacyScreen.setEnabled(true)).called(1);
      verify(
        () => authenticator.authenticate(
          messages: testMessages,
          allowDeviceCredential: true,
        ),
      ).called(1);
    });

    test('enabling keeps the switch off when the prompt fails', () async {
      await service.init();
      stubPrompt(DeviceAuthOutcome.cancelled);

      final outcome = await service.setEnabled(true, messages: testMessages);

      expect(outcome, DeviceAuthOutcome.cancelled);
      expect(service.state.enabled, isFalse);
      verifyNever(() => storage.setEnabled(any()));
    });

    test('disabling runs the prompt and persists on success', () async {
      await initEnabled();
      stubPrompt(DeviceAuthOutcome.success);

      final outcome = await service.setEnabled(false, messages: testMessages);

      expect(outcome, DeviceAuthOutcome.success);
      expect(service.state.enabled, isFalse);
      expect(service.state.locked, isFalse);
      verify(() => storage.setEnabled(false)).called(1);
      verify(() => privacyScreen.setEnabled(false)).called(1);
    });

    test('disabling keeps the lock on when the prompt fails', () async {
      await initEnabled();
      stubPrompt(DeviceAuthOutcome.failed);

      await service.setEnabled(false, messages: testMessages);

      expect(service.state.enabled, isTrue);
      verifyNever(() => storage.setEnabled(any()));
    });

    test(
      'uses the persisted device credential preference for the prompt',
      () async {
        when(
          () => storage.isDeviceCredentialAllowed(),
        ).thenAnswer((_) async => false);
        await service.init();
        stubPrompt(DeviceAuthOutcome.success);

        await service.setEnabled(true, messages: testMessages);

        verify(
          () => authenticator.authenticate(
            messages: testMessages,
            allowDeviceCredential: false,
          ),
        ).called(1);
      },
    );

    test('is a no-op when the value does not change', () async {
      await service.init();
      final outcome = await service.setEnabled(false, messages: testMessages);
      expect(outcome, DeviceAuthOutcome.success);
      verifyNever(
        () => authenticator.authenticate(
          messages: any(named: 'messages'),
          allowDeviceCredential: any(named: 'allowDeviceCredential'),
        ),
      );
    });

    test('rethrows a persistence failure and keeps state', () async {
      await service.init();
      stubPrompt(DeviceAuthOutcome.success);
      when(() => storage.setEnabled(any())).thenThrow(Exception('disk'));

      await expectLater(
        service.setEnabled(true, messages: testMessages),
        throwsException,
      );
      expect(service.state.enabled, isFalse);
      verifyNever(() => privacyScreen.setEnabled(true));
    });
  });

  group('sub-settings', () {
    test('setGrace persists and emits without a prompt', () async {
      await service.init();
      await service.setGrace(AppLockGrace.fifteenMinutes);
      expect(service.state.grace, AppLockGrace.fifteenMinutes);
      verify(() => storage.setGrace(AppLockGrace.fifteenMinutes)).called(1);
      verifyNever(
        () => authenticator.authenticate(
          messages: any(named: 'messages'),
          allowDeviceCredential: any(named: 'allowDeviceCredential'),
        ),
      );
    });

    test('allowing the device credential needs no prompt', () async {
      when(
        () => storage.isDeviceCredentialAllowed(),
      ).thenAnswer((_) async => false);
      await service.init();

      final outcome = await service.setDeviceCredentialAllowed(
        true,
        messages: testMessages,
      );

      expect(outcome, DeviceAuthOutcome.success);
      expect(service.state.deviceCredentialAllowed, isTrue);
      verify(() => storage.setDeviceCredentialAllowed(true)).called(1);
      verifyNever(
        () => authenticator.authenticate(
          messages: any(named: 'messages'),
          allowDeviceCredential: any(named: 'allowDeviceCredential'),
        ),
      );
    });

    test(
      'refusing the device credential first proves a biometric works',
      () async {
        await service.init();
        stubPrompt(DeviceAuthOutcome.success);

        final outcome = await service.setDeviceCredentialAllowed(
          false,
          messages: testMessages,
        );

        expect(outcome, DeviceAuthOutcome.success);
        expect(service.state.deviceCredentialAllowed, isFalse);
        verify(() => storage.setDeviceCredentialAllowed(false)).called(1);
        verify(
          () => authenticator.authenticate(
            messages: testMessages,
            allowDeviceCredential: false,
          ),
        ).called(1);
      },
    );

    test(
      'keeps the device credential allowed when no biometric passes',
      () async {
        await service.init();
        stubPrompt(DeviceAuthOutcome.noBiometrics);

        final outcome = await service.setDeviceCredentialAllowed(
          false,
          messages: testMessages,
        );

        expect(outcome, DeviceAuthOutcome.noBiometrics);
        expect(service.state.deviceCredentialAllowed, isTrue);
        verifyNever(() => storage.setDeviceCredentialAllowed(any()));
      },
    );
  });

  group('lifecycle', () {
    test('does not lock when foregrounded before the grace period', () async {
      await initEnabled();
      stubPrompt(DeviceAuthOutcome.success);
      await service.unlock(messages: testMessages);

      service.onBackgrounded();
      now = now.add(const Duration(seconds: 59));
      service.onForegrounded();

      expect(service.state.locked, isFalse);
    });

    test('locks when foregrounded at or after the grace period', () async {
      await initEnabled();
      stubPrompt(DeviceAuthOutcome.success);
      await service.unlock(messages: testMessages);

      service.onBackgrounded();
      now = now.add(const Duration(seconds: 60));
      service.onForegrounded();

      expect(service.state.locked, isTrue);
    });

    test('locks on every return when grace is immediately', () async {
      await initEnabled(grace: AppLockGrace.immediately);
      stubPrompt(DeviceAuthOutcome.success);
      await service.unlock(messages: testMessages);

      service.onBackgrounded();
      service.onForegrounded();

      expect(service.state.locked, isTrue);
    });

    test('never locks while the lock is disabled', () async {
      await service.init();
      service.onBackgrounded();
      now = now.add(const Duration(hours: 1));
      service.onForegrounded();
      expect(service.state.locked, isFalse);
    });

    test('ignores a foreground without a preceding background', () async {
      await initEnabled(grace: AppLockGrace.immediately);
      stubPrompt(DeviceAuthOutcome.success);
      await service.unlock(messages: testMessages);

      service.onForegrounded();

      expect(service.state.locked, isFalse);
    });

    test('ignores lifecycle churn caused by the prompt itself', () async {
      await initEnabled(grace: AppLockGrace.immediately);
      final prompt = Completer<DeviceAuthOutcome>();
      when(
        () => authenticator.authenticate(
          messages: any(named: 'messages'),
          allowDeviceCredential: any(named: 'allowDeviceCredential'),
        ),
      ).thenAnswer((_) => prompt.future);

      final unlocking = service.unlock(messages: testMessages);
      expect(service.state.isAuthenticating, isTrue);
      service.onBackgrounded();
      service.onForegrounded();
      prompt.complete(DeviceAuthOutcome.success);
      await unlocking;

      expect(service.state.locked, isFalse);
      expect(service.state.isAuthenticating, isFalse);

      // The churn must not leave a stale background timestamp behind either.
      service.onForegrounded();
      expect(service.state.locked, isFalse);
    });
  });

  group('prompt interrupted by backgrounding', () {
    test(
      'counts the time away when the prompt was cancelled by the system',
      () async {
        await initEnabled();
        stubPrompt(DeviceAuthOutcome.success);
        await service.unlock(messages: testMessages);

        final prompt = Completer<DeviceAuthOutcome>();
        when(
          () => authenticator.authenticate(
            messages: any(named: 'messages'),
            allowDeviceCredential: any(named: 'allowDeviceCredential'),
          ),
        ).thenAnswer((_) => prompt.future);
        final disabling = service.setEnabled(false, messages: testMessages);
        service.onBackgrounded();
        prompt.complete(DeviceAuthOutcome.cancelled);
        await disabling;
        expect(service.state.enabled, isTrue);

        now = now.add(const Duration(hours: 1));
        service.onForegrounded();

        expect(service.state.locked, isTrue);
      },
    );

    test(
      'a successful unlock while paused does not re-lock on resume',
      () async {
        // Android API 21-29: the device-credential screen pauses the activity,
        // the success arrives, and only then does `resumed` fire.
        await initEnabled(grace: AppLockGrace.immediately);
        final prompt = Completer<DeviceAuthOutcome>();
        when(
          () => authenticator.authenticate(
            messages: any(named: 'messages'),
            allowDeviceCredential: any(named: 'allowDeviceCredential'),
          ),
        ).thenAnswer((_) => prompt.future);

        final unlocking = service.unlock(messages: testMessages);
        service.onBackgrounded();
        now = now.add(const Duration(seconds: 20));
        prompt.complete(DeviceAuthOutcome.success);
        await unlocking;
        service.onForegrounded();

        expect(service.state.locked, isFalse);
      },
    );

    test('does not lock when the app stayed in the foreground', () async {
      await initEnabled();
      stubPrompt(DeviceAuthOutcome.success);
      await service.unlock(messages: testMessages);

      // Android: the device-credential screen pauses and resumes the
      // activity while the user is still "here".
      final prompt = Completer<DeviceAuthOutcome>();
      when(
        () => authenticator.authenticate(
          messages: any(named: 'messages'),
          allowDeviceCredential: any(named: 'allowDeviceCredential'),
        ),
      ).thenAnswer((_) => prompt.future);
      final disabling = service.setEnabled(false, messages: testMessages);
      service.onBackgrounded();
      now = now.add(const Duration(hours: 1));
      service.onForegrounded();
      prompt.complete(DeviceAuthOutcome.cancelled);
      await disabling;

      expect(service.state.locked, isFalse);
      service.onForegrounded();
      expect(service.state.locked, isFalse);
    });
  });

  group('device support', () {
    test('is re-checked when the app returns to the foreground', () async {
      when(
        () => authenticator.isDeviceSupported(),
      ).thenAnswer((_) async => false);
      await service.init();
      expect(service.state.isSupported, isFalse);

      when(
        () => authenticator.isDeviceSupported(),
      ).thenAnswer((_) async => true);
      service.onBackgrounded();
      service.onForegrounded();
      await Future<void>.delayed(Duration.zero);

      expect(service.state.isSupported, isTrue);
    });
  });

  group('unlock', () {
    test('succeeds and clears the last outcome', () async {
      await initEnabled();
      stubPrompt(DeviceAuthOutcome.failed);
      await service.unlock(messages: testMessages);
      expect(service.state.lastOutcome, DeviceAuthOutcome.failed);

      stubPrompt(DeviceAuthOutcome.success);
      final outcome = await service.unlock(messages: testMessages);

      expect(outcome, DeviceAuthOutcome.success);
      expect(service.state.locked, isFalse);
      expect(service.state.lastOutcome, isNull);
    });

    test('clears the previous outcome while a new prompt is open', () async {
      await initEnabled();
      stubPrompt(DeviceAuthOutcome.cancelled);
      await service.unlock(messages: testMessages);
      expect(service.state.lastOutcome, DeviceAuthOutcome.cancelled);

      final prompt = Completer<DeviceAuthOutcome>();
      when(
        () => authenticator.authenticate(
          messages: any(named: 'messages'),
          allowDeviceCredential: any(named: 'allowDeviceCredential'),
        ),
      ).thenAnswer((_) => prompt.future);
      final unlocking = service.unlock(messages: testMessages);
      expect(service.state.lastOutcome, isNull);
      prompt.complete(DeviceAuthOutcome.cancelled);
      await unlocking;
      expect(service.state.lastOutcome, DeviceAuthOutcome.cancelled);
    });

    test('stays locked and records the outcome on failure', () async {
      await initEnabled();
      stubPrompt(DeviceAuthOutcome.lockedOut);

      final outcome = await service.unlock(messages: testMessages);

      expect(outcome, DeviceAuthOutcome.lockedOut);
      expect(service.state.locked, isTrue);
      expect(service.state.lastOutcome, DeviceAuthOutcome.lockedOut);
    });

    test('returns success without a prompt when not locked', () async {
      await service.init();
      final outcome = await service.unlock(messages: testMessages);
      expect(outcome, DeviceAuthOutcome.success);
      verifyNever(
        () => authenticator.authenticate(
          messages: any(named: 'messages'),
          allowDeviceCredential: any(named: 'allowDeviceCredential'),
        ),
      );
    });

    test('shares one in-flight prompt between concurrent callers', () async {
      await initEnabled();
      final prompt = Completer<DeviceAuthOutcome>();
      when(
        () => authenticator.authenticate(
          messages: any(named: 'messages'),
          allowDeviceCredential: any(named: 'allowDeviceCredential'),
        ),
      ).thenAnswer((_) => prompt.future);

      final first = service.unlock(messages: testMessages);
      final second = service.unlock(messages: testMessages);
      prompt.complete(DeviceAuthOutcome.success);

      expect(await first, DeviceAuthOutcome.success);
      expect(await second, DeviceAuthOutcome.success);
      verify(
        () => authenticator.authenticate(
          messages: any(named: 'messages'),
          allowDeviceCredential: any(named: 'allowDeviceCredential'),
        ),
      ).called(1);
    });

    test('emits isAuthenticating around the prompt', () async {
      await initEnabled();
      final prompt = Completer<DeviceAuthOutcome>();
      when(
        () => authenticator.authenticate(
          messages: any(named: 'messages'),
          allowDeviceCredential: any(named: 'allowDeviceCredential'),
        ),
      ).thenAnswer((_) => prompt.future);
      final seen = <bool>[];
      final sub = service.stateStream
          .map((s) => s.isAuthenticating)
          .distinct()
          .listen(seen.add);

      final unlocking = service.unlock(messages: testMessages);
      await Future<void>.delayed(Duration.zero);
      prompt.complete(DeviceAuthOutcome.success);
      await unlocking;
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(seen, [false, true, false]);
    });
  });
}
