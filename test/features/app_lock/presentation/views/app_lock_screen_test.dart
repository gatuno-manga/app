import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/app_lock/domain/device_authenticator.dart';
import 'package:gatuno/features/app_lock/presentation/views/app_lock_screen.dart';
import 'package:gatuno/shared/components/atoms/app_button.dart';
import 'package:gatuno/shared/components/atoms/app_loading_indicator.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('omits the PIN from the message when the fallback is off', (
    tester,
  ) async {
    await tester.pumpApp(
      AppLockScreen(
        isAuthenticating: false,
        allowDeviceCredential: false,
        lastOutcome: null,
        onUnlock: () {},
      ),
    );

    expect(
      find.text('Use your fingerprint or face to continue'),
      findsOneWidget,
    );
    expect(
      find.text('Use your fingerprint, face or device PIN to continue'),
      findsNothing,
    );
  });

  testWidgets('shows the locked message and an Unlock button', (tester) async {
    var taps = 0;
    await tester.pumpApp(
      AppLockScreen(
        isAuthenticating: false,
        allowDeviceCredential: true,
        lastOutcome: null,
        onUnlock: () => taps++,
      ),
    );

    expect(find.text('Gatuno is locked'), findsOneWidget);
    expect(
      find.text('Use your fingerprint, face or device PIN to continue'),
      findsOneWidget,
    );
    expect(find.widgetWithText(AppButton, 'Unlock'), findsOneWidget);

    await tester.tap(find.byType(AppButton));
    expect(taps, 1);
  });

  testWidgets('the button keeps a full, bounded width across states', (
    tester,
  ) async {
    await tester.pumpApp(
      AppLockScreen(
        isAuthenticating: false,
        allowDeviceCredential: true,
        lastOutcome: null,
        onUnlock: () {},
      ),
    );
    final idle = tester.getSize(find.byType(AppButton)).width;
    await tester.pumpApp(
      AppLockScreen(
        isAuthenticating: true,
        allowDeviceCredential: true,
        lastOutcome: null,
        onUnlock: () {},
      ),
    );
    final busy = tester.getSize(find.byType(AppButton)).width;

    expect(idle, busy);
    expect(idle, greaterThan(300));
    expect(idle, lessThanOrEqualTo(480));
  });

  testWidgets('a sensorless outcome on the cover does not mention settings', (
    tester,
  ) async {
    await tester.pumpApp(
      AppLockScreen(
        isAuthenticating: false,
        allowDeviceCredential: false,
        lastOutcome: DeviceAuthOutcome.noBiometricHardware,
        onUnlock: () {},
      ),
    );

    expect(
      find.text('No fingerprint or face sensor is available on this device.'),
      findsOneWidget,
    );
  });

  testWidgets('shows the failure reason and a Try again button', (
    tester,
  ) async {
    await tester.pumpApp(
      AppLockScreen(
        isAuthenticating: false,
        allowDeviceCredential: true,
        lastOutcome: DeviceAuthOutcome.lockedOut,
        onUnlock: () {},
      ),
    );

    expect(
      find.text('Too many attempts. Biometrics are locked for now.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(AppButton, 'Try again'), findsOneWidget);
    expect(find.text('Unlock'), findsNothing);
  });

  testWidgets('a cancel reads as neutral, a failure as an error', (
    tester,
  ) async {
    await tester.pumpApp(
      AppLockScreen(
        isAuthenticating: false,
        allowDeviceCredential: true,
        lastOutcome: DeviceAuthOutcome.cancelled,
        onUnlock: () {},
      ),
    );
    final cancelText = find.text('Unlock cancelled');
    expect(
      tester.widget<Text>(cancelText).style?.color,
      isNot(Theme.of(tester.element(cancelText)).colorScheme.error),
    );

    await tester.pumpApp(
      AppLockScreen(
        isAuthenticating: false,
        allowDeviceCredential: true,
        lastOutcome: DeviceAuthOutcome.failed,
        onUnlock: () {},
      ),
    );
    final failText = find.text("Could not verify it's you. Try again.");
    expect(
      tester.widget<Text>(failText).style?.color,
      Theme.of(tester.element(failText)).colorScheme.error,
    );
  });

  testWidgets('the title is a heading for screen-reader navigation', (
    tester,
  ) async {
    await tester.pumpApp(
      AppLockScreen(
        isAuthenticating: false,
        allowDeviceCredential: true,
        lastOutcome: null,
        onUnlock: () {},
      ),
    );

    final node = tester.getSemantics(find.text('Gatuno is locked'));
    expect(node.flagsCollection.isHeader, isTrue);
  });

  testWidgets('disables the button while the prompt is open', (tester) async {
    var taps = 0;
    await tester.pumpApp(
      AppLockScreen(
        isAuthenticating: true,
        allowDeviceCredential: true,
        lastOutcome: null,
        onUnlock: () => taps++,
      ),
    );

    expect(find.byType(AppLoadingIndicator), findsOneWidget);
    await tester.tap(find.byType(AppButton), warnIfMissed: false);
    expect(taps, 0);
  });
}
