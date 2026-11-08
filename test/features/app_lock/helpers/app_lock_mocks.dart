import 'dart:async';

import 'package:gatuno/features/app_lock/domain/device_authenticator.dart';
import 'package:gatuno/features/app_lock/domain/use_cases/app_lock_service.dart';
import 'package:gatuno/features/app_lock/domain/value_objects/app_lock_grace.dart';
import 'package:mocktail/mocktail.dart';

class MockAppLockService extends Mock implements AppLockService {}

/// A mock service backed by a broadcast controller so tests can push states.
class FakeAppLockService {
  final MockAppLockService mock = MockAppLockService();
  final StreamController<AppLockState> controller =
      StreamController<AppLockState>.broadcast();
  AppLockState _state;

  FakeAppLockService([AppLockState initial = const AppLockState()])
    : _state = initial {
    registerFallbackValue(AppLockGrace.oneMinute);
    when(() => mock.stateStream).thenAnswer((_) => controller.stream);
    when(() => mock.state).thenAnswer((_) => _state);
    when(
      () => mock.unlock(reason: any(named: 'reason')),
    ).thenAnswer((_) async => DeviceAuthOutcome.success);
    when(
      () => mock.setEnabled(any(), reason: any(named: 'reason')),
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
