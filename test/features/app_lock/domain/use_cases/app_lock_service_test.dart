import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/app_lock/data/data_sources/app_lock_local_data_source.dart';
import 'package:gatuno/features/app_lock/domain/device_authenticator.dart';
import 'package:gatuno/features/app_lock/domain/privacy_screen.dart';
import 'package:gatuno/features/app_lock/domain/use_cases/app_lock_service.dart';
import 'package:gatuno/features/app_lock/domain/value_objects/app_lock_grace.dart';
import 'package:mocktail/mocktail.dart';

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
        reason: any(named: 'reason'),
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

      final outcome = await service.setEnabled(true, reason: 'r');

      expect(outcome, DeviceAuthOutcome.success);
      expect(service.state.enabled, isTrue);
      expect(service.state.locked, isFalse);
      verify(() => storage.setEnabled(true)).called(1);
      verify(() => privacyScreen.setEnabled(true)).called(1);
      verify(
        () => authenticator.authenticate(
          reason: 'r',
          allowDeviceCredential: true,
        ),
      ).called(1);
    });

    test('enabling keeps the switch off when the prompt fails', () async {
      await service.init();
      stubPrompt(DeviceAuthOutcome.cancelled);

      final outcome = await service.setEnabled(true, reason: 'r');

      expect(outcome, DeviceAuthOutcome.cancelled);
      expect(service.state.enabled, isFalse);
      verifyNever(() => storage.setEnabled(any()));
    });

    test('disabling runs the prompt and persists on success', () async {
      await initEnabled();
      stubPrompt(DeviceAuthOutcome.success);

      final outcome = await service.setEnabled(false, reason: 'r');

      expect(outcome, DeviceAuthOutcome.success);
      expect(service.state.enabled, isFalse);
      expect(service.state.locked, isFalse);
      verify(() => storage.setEnabled(false)).called(1);
      verify(() => privacyScreen.setEnabled(false)).called(1);
    });

    test('disabling keeps the lock on when the prompt fails', () async {
      await initEnabled();
      stubPrompt(DeviceAuthOutcome.failed);

      await service.setEnabled(false, reason: 'r');

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

        await service.setEnabled(true, reason: 'r');

        verify(
          () => authenticator.authenticate(
            reason: 'r',
            allowDeviceCredential: false,
          ),
        ).called(1);
      },
    );

    test('is a no-op when the value does not change', () async {
      await service.init();
      final outcome = await service.setEnabled(false, reason: 'r');
      expect(outcome, DeviceAuthOutcome.success);
      verifyNever(
        () => authenticator.authenticate(
          reason: any(named: 'reason'),
          allowDeviceCredential: any(named: 'allowDeviceCredential'),
        ),
      );
    });

    test('reports failed and keeps state when persisting throws', () async {
      await service.init();
      stubPrompt(DeviceAuthOutcome.success);
      when(() => storage.setEnabled(any())).thenThrow(Exception('disk'));

      final outcome = await service.setEnabled(true, reason: 'r');

      expect(outcome, DeviceAuthOutcome.failed);
      expect(service.state.enabled, isFalse);
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
          reason: any(named: 'reason'),
          allowDeviceCredential: any(named: 'allowDeviceCredential'),
        ),
      );
    });

    test('setDeviceCredentialAllowed persists and emits', () async {
      await service.init();
      await service.setDeviceCredentialAllowed(false);
      expect(service.state.deviceCredentialAllowed, isFalse);
      verify(() => storage.setDeviceCredentialAllowed(false)).called(1);
    });
  });

  group('lifecycle', () {
    test('does not lock when foregrounded before the grace period', () async {
      await initEnabled();
      stubPrompt(DeviceAuthOutcome.success);
      await service.unlock(reason: 'r');

      service.onBackgrounded();
      now = now.add(const Duration(seconds: 59));
      service.onForegrounded();

      expect(service.state.locked, isFalse);
    });

    test('locks when foregrounded at or after the grace period', () async {
      await initEnabled();
      stubPrompt(DeviceAuthOutcome.success);
      await service.unlock(reason: 'r');

      service.onBackgrounded();
      now = now.add(const Duration(seconds: 60));
      service.onForegrounded();

      expect(service.state.locked, isTrue);
    });

    test('locks on every return when grace is immediately', () async {
      await initEnabled(grace: AppLockGrace.immediately);
      stubPrompt(DeviceAuthOutcome.success);
      await service.unlock(reason: 'r');

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
      await service.unlock(reason: 'r');

      service.onForegrounded();

      expect(service.state.locked, isFalse);
    });

    test('ignores lifecycle churn caused by the prompt itself', () async {
      await initEnabled(grace: AppLockGrace.immediately);
      final prompt = Completer<DeviceAuthOutcome>();
      when(
        () => authenticator.authenticate(
          reason: any(named: 'reason'),
          allowDeviceCredential: any(named: 'allowDeviceCredential'),
        ),
      ).thenAnswer((_) => prompt.future);

      final unlocking = service.unlock(reason: 'r');
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

  group('unlock', () {
    test('succeeds and clears the last outcome', () async {
      await initEnabled();
      stubPrompt(DeviceAuthOutcome.failed);
      await service.unlock(reason: 'r');
      expect(service.state.lastOutcome, DeviceAuthOutcome.failed);

      stubPrompt(DeviceAuthOutcome.success);
      final outcome = await service.unlock(reason: 'r');

      expect(outcome, DeviceAuthOutcome.success);
      expect(service.state.locked, isFalse);
      expect(service.state.lastOutcome, isNull);
    });

    test('stays locked and records the outcome on failure', () async {
      await initEnabled();
      stubPrompt(DeviceAuthOutcome.lockedOut);

      final outcome = await service.unlock(reason: 'r');

      expect(outcome, DeviceAuthOutcome.lockedOut);
      expect(service.state.locked, isTrue);
      expect(service.state.lastOutcome, DeviceAuthOutcome.lockedOut);
    });

    test('returns success without a prompt when not locked', () async {
      await service.init();
      final outcome = await service.unlock(reason: 'r');
      expect(outcome, DeviceAuthOutcome.success);
      verifyNever(
        () => authenticator.authenticate(
          reason: any(named: 'reason'),
          allowDeviceCredential: any(named: 'allowDeviceCredential'),
        ),
      );
    });

    test('shares one in-flight prompt between concurrent callers', () async {
      await initEnabled();
      final prompt = Completer<DeviceAuthOutcome>();
      when(
        () => authenticator.authenticate(
          reason: any(named: 'reason'),
          allowDeviceCredential: any(named: 'allowDeviceCredential'),
        ),
      ).thenAnswer((_) => prompt.future);

      final first = service.unlock(reason: 'r');
      final second = service.unlock(reason: 'r');
      prompt.complete(DeviceAuthOutcome.success);

      expect(await first, DeviceAuthOutcome.success);
      expect(await second, DeviceAuthOutcome.success);
      verify(
        () => authenticator.authenticate(
          reason: any(named: 'reason'),
          allowDeviceCredential: any(named: 'allowDeviceCredential'),
        ),
      ).called(1);
    });

    test('emits isAuthenticating around the prompt', () async {
      await initEnabled();
      final prompt = Completer<DeviceAuthOutcome>();
      when(
        () => authenticator.authenticate(
          reason: any(named: 'reason'),
          allowDeviceCredential: any(named: 'allowDeviceCredential'),
        ),
      ).thenAnswer((_) => prompt.future);
      final seen = <bool>[];
      final sub = service.stateStream
          .map((s) => s.isAuthenticating)
          .distinct()
          .listen(seen.add);

      final unlocking = service.unlock(reason: 'r');
      await Future<void>.delayed(Duration.zero);
      prompt.complete(DeviceAuthOutcome.success);
      await unlocking;
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(seen, [false, true, false]);
    });
  });
}
