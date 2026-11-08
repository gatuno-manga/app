import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/app_lock/domain/device_authenticator.dart';
import 'package:gatuno/features/app_lock/presentation/views/app_lock_screen.dart';
import 'package:gatuno/shared/components/atoms/app_button.dart';
import 'package:gatuno/shared/components/atoms/app_loading_indicator.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows the locked message and an Unlock button', (tester) async {
    var taps = 0;
    await tester.pumpApp(
      AppLockScreen(
        isAuthenticating: false,
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

  testWidgets('shows the failure reason and a Try again button', (
    tester,
  ) async {
    await tester.pumpApp(
      AppLockScreen(
        isAuthenticating: false,
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

  testWidgets('disables the button while the prompt is open', (tester) async {
    var taps = 0;
    await tester.pumpApp(
      AppLockScreen(
        isAuthenticating: true,
        lastOutcome: null,
        onUnlock: () => taps++,
      ),
    );

    expect(find.byType(AppLoadingIndicator), findsOneWidget);
    await tester.tap(find.byType(AppButton), warnIfMissed: false);
    expect(taps, 0);
  });
}
