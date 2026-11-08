import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/app_lock/domain/device_authenticator.dart';
import 'package:gatuno/features/app_lock/domain/use_cases/app_lock_service.dart';
import 'package:gatuno/features/app_lock/domain/value_objects/app_lock_grace.dart';
import 'package:gatuno/features/app_lock/presentation/views/app_lock_settings_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';
import '../../helpers/app_lock_mocks.dart';

void main() {
  late FakeAppLockService fake;

  const supportedOff = AppLockState(isSupported: true, isInitialized: true);
  const supportedOn = AppLockState(
    isSupported: true,
    enabled: true,
    grace: AppLockGrace.oneMinute,
    isInitialized: true,
  );

  tearDown(() => fake.close());

  Future<void> pumpPage(WidgetTester tester, AppLockState state) async {
    fake = FakeAppLockService(state);
    await tester.pumpApp(AppLockSettingsPage(service: fake.mock));
  }

  Finder switchWithTitle(String title) => find.descendant(
    of: find.ancestor(
      of: find.text(title),
      matching: find.byType(SwitchListTile),
    ),
    matching: find.byType(Switch),
  );

  testWidgets('explains when the device has no screen lock', (tester) async {
    await pumpPage(tester, const AppLockState(isInitialized: true));

    expect(
      find.text('This device has no screen lock, so Gatuno cannot be locked.'),
      findsOneWidget,
    );
    expect(find.byType(Switch), findsNothing);
  });

  testWidgets('shows only the main switch while the lock is off', (
    tester,
  ) async {
    await pumpPage(tester, supportedOff);

    expect(find.text('App lock'), findsOneWidget);
    expect(find.text('Lock Gatuno'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
    expect(find.text('Lock after leaving the app'), findsNothing);
  });

  testWidgets('shows grace options and fallback while the lock is on', (
    tester,
  ) async {
    await pumpPage(tester, supportedOn);

    expect(find.text('Lock after leaving the app'), findsOneWidget);
    for (final label in [
      'Immediately',
      'After 30 seconds',
      'After 1 minute',
      'After 5 minutes',
      'After 15 minutes',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    final group = tester.widget<RadioGroup<AppLockGrace>>(
      find.byType(RadioGroup<AppLockGrace>),
    );
    expect(group.groupValue, AppLockGrace.oneMinute);
    expect(find.text('Allow device PIN, pattern or passcode'), findsOneWidget);
    expect(
      find.text('Used when your fingerprint or face is unavailable'),
      findsOneWidget,
    );
  });

  testWidgets('turning the lock on asks the service with the prompt reason', (
    tester,
  ) async {
    await pumpPage(tester, supportedOff);

    await tester.tap(switchWithTitle('Lock Gatuno'));
    await tester.pump();

    verify(
      () => fake.mock.setEnabled(
        true,
        reason: "Confirm it's you to change the app lock",
      ),
    ).called(1);
  });

  testWidgets('a refused prompt shows the reason in a snackbar', (
    tester,
  ) async {
    await pumpPage(tester, supportedOff);
    when(
      () => fake.mock.setEnabled(any(), reason: any(named: 'reason')),
    ).thenAnswer((_) async => DeviceAuthOutcome.noCredentials);

    await tester.tap(switchWithTitle('Lock Gatuno'));
    await tester.pump();

    expect(
      find.text(
        'No screen lock is set on this device. Set one in the system settings.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('a cancelled prompt leaves the switch alone silently', (
    tester,
  ) async {
    await pumpPage(tester, supportedOff);
    when(
      () => fake.mock.setEnabled(any(), reason: any(named: 'reason')),
    ).thenAnswer((_) async => DeviceAuthOutcome.cancelled);

    await tester.tap(switchWithTitle('Lock Gatuno'));
    await tester.pump();

    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('Unlock cancelled'), findsNothing);
  });

  testWidgets('choosing a grace period persists it', (tester) async {
    await pumpPage(tester, supportedOn);

    await tester.tap(find.text('After 5 minutes'));
    await tester.pump();

    verify(() => fake.mock.setGrace(AppLockGrace.fiveMinutes)).called(1);
  });

  testWidgets('the fallback switch warns when off and persists changes', (
    tester,
  ) async {
    await pumpPage(
      tester,
      supportedOn.copyWith(deviceCredentialAllowed: false),
    );

    expect(
      find.text(
        'If biometrics get locked out, Gatuno stays locked until the device allows them again',
      ),
      findsOneWidget,
    );

    await tester.tap(switchWithTitle('Allow device PIN, pattern or passcode'));
    await tester.pump();

    verify(() => fake.mock.setDeviceCredentialAllowed(true)).called(1);
  });
}
