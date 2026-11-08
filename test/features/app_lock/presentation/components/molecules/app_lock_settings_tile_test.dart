import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/di/injection.dart';
import 'package:gatuno/features/app_lock/domain/use_cases/app_lock_service.dart';
import 'package:gatuno/features/app_lock/presentation/components/molecules/app_lock_settings_tile.dart';

import '../../../../../helpers/pump_app.dart';
import '../../../../../helpers/test_injection.dart';
import '../../../helpers/app_lock_mocks.dart';

void main() {
  late FakeAppLockService fake;

  Future<void> pumpTile(
    WidgetTester tester,
    AppLockState state, {
    VoidCallback? onTap,
  }) async {
    fake = FakeAppLockService(state);
    await initTestDI();
    sl.registerLazySingleton<AppLockService>(() => fake.mock);
    await tester.pumpApp(
      Scaffold(body: AppLockSettingsTile(onTap: onTap ?? () {})),
    );
  }

  tearDown(() => fake.close());

  testWidgets('renders the entry and reports taps on a supported device', (
    tester,
  ) async {
    var taps = 0;
    await pumpTile(
      tester,
      const AppLockState(isSupported: true, isInitialized: true),
      onTap: () => taps++,
    );

    expect(find.text('App lock'), findsOneWidget);
    expect(
      find.text('Require your fingerprint, face or device PIN to open Gatuno'),
      findsOneWidget,
    );
    await tester.tap(find.byType(ListTile));
    expect(taps, 1);
  });

  testWidgets('renders nothing when the device has no screen lock', (
    tester,
  ) async {
    await pumpTile(tester, const AppLockState(isInitialized: true));

    expect(find.byType(ListTile), findsNothing);
    expect(find.text('App lock'), findsNothing);
  });

  testWidgets('appears once support is reported later', (tester) async {
    await pumpTile(tester, const AppLockState());
    expect(find.byType(ListTile), findsNothing);

    fake.emit(const AppLockState(isSupported: true, isInitialized: true));
    await tester.pump();

    expect(find.byType(ListTile), findsOneWidget);
  });
}
