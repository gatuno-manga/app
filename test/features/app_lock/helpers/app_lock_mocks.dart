import 'dart:async';

import 'package:gatuno/features/app_lock/domain/device_authenticator.dart';
import 'package:gatuno/features/app_lock/domain/use_cases/app_lock_service.dart';
import 'package:gatuno/features/app_lock/domain/value_objects/app_lock_grace.dart';
import 'package:mocktail/mocktail.dart';

class MockAppLockService extends Mock implements AppLockService {}

const testMessages = DeviceAuthMessages(
  reason: 'r',
  title: 't',
  hint: 'h',
  cancel: 'c',
);

/// What the gate builds from the EN strings.
const unlockMessages = DeviceAuthMessages(
  reason: 'Unlock Gatuno',
  title: 'Gatuno is locked',
  hint: 'Use your fingerprint or face',
  cancel: 'Cancel',
);

/// What the settings page builds from the EN strings.
const confirmMessages = DeviceAuthMessages(
  reason: "Confirm it's you to change the app lock",
  title: 'App lock',
  hint: 'Use your fingerprint or face',
  cancel: 'Cancel',
);

/// A mock service backed by a broadcast controller so tests can push states.
class FakeAppLockService {
  final MockAppLockService mock = MockAppLockService();
  final StreamController<AppLockState> controller =
      StreamController<AppLockState>.broadcast();
  AppLockState _state;

  FakeAppLockService([AppLockState initial = const AppLockState()])
    : _state = initial {
    registerFallbackValue(AppLockGrace.oneMinute);
    registerFallbackValue(testMessages);
    when(() => mock.stateStream).thenAnswer((_) => controller.stream);
    when(() => mock.state).thenAnswer((_) => _state);
    when(
      () => mock.unlock(messages: any(named: 'messages')),
    ).thenAnswer((_) async => DeviceAuthOutcome.success);
    when(
      () => mock.setEnabled(any(), messages: any(named: 'messages')),
    ).thenAnswer((_) async => DeviceAuthOutcome.success);
    when(() => mock.setGrace(any())).thenAnswer((_) async {});
    when(() => mock.setDeviceCredentialAllowed(any())).thenAnswer((_) async {});
    when(() => mock.onBackgrounded()).thenReturn(null);
    when(() => mock.onForegrounded()).thenReturn(null);
  }

  AppLockState get state => _state;

  void emit(AppLockState next) {
    _state = next;
    controller.add(next);
  }

  Future<void> close() => controller.close();
}
