import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/app_lock/domain/device_authenticator.dart';
import 'package:gatuno/features/app_lock/domain/use_cases/app_lock_service.dart';
import 'package:gatuno/features/app_lock/domain/value_objects/app_lock_grace.dart';
import 'package:gatuno/features/app_lock/presentation/view_models/app_lock_settings_view_model.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/app_lock_mocks.dart';

void main() {
  late FakeAppLockService fake;
  late AppLockSettingsViewModel viewModel;

  setUp(() {
    fake = FakeAppLockService(
      const AppLockState(isSupported: true, isInitialized: true),
    );
    viewModel = AppLockSettingsViewModel(fake.mock);
  });

  tearDown(() async {
    viewModel.dispose();
    await fake.close();
  });

  test('starts from the service state and follows its stream', () async {
    expect(viewModel.state.isSupported, isTrue);
    expect(viewModel.state.enabled, isFalse);

    fake.emit(
      fake.state.copyWith(enabled: true, grace: AppLockGrace.fiveMinutes),
    );
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.state.enabled, isTrue);
    expect(viewModel.state.grace, AppLockGrace.fiveMinutes);
  });

  test('setEnabled delegates and returns the outcome', () async {
    when(
      () => fake.mock.setEnabled(true, reason: 'why'),
    ).thenAnswer((_) async => DeviceAuthOutcome.cancelled);

    expect(
      await viewModel.setEnabled(true, reason: 'why'),
      DeviceAuthOutcome.cancelled,
    );
  });

  test('setGrace and setDeviceCredentialAllowed delegate', () async {
    await viewModel.setGrace(AppLockGrace.immediately);
    await viewModel.setDeviceCredentialAllowed(false);

    verify(() => fake.mock.setGrace(AppLockGrace.immediately)).called(1);
    verify(() => fake.mock.setDeviceCredentialAllowed(false)).called(1);
  });
}
