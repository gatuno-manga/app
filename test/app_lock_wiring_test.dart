import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/di/injection.dart';
import 'package:gatuno/core/theme/app_theme_choice.dart';
import 'package:gatuno/features/app_lock/domain/use_cases/app_lock_service.dart';
import 'package:gatuno/features/app_lock/presentation/components/organisms/app_lock_gate.dart';
import 'package:gatuno/features/settings/domain/use_cases/settings_service.dart';
import 'package:gatuno/main.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'features/app_lock/helpers/app_lock_mocks.dart';
import 'helpers/test_injection.dart';

void main() {
  testWidgets('App mounts the lock gate inside MaterialApp, above the router', (
    tester,
  ) async {
    final settings = MockSettingsService();
    when(() => settings.settingsStream).thenAnswer((_) => const Stream.empty());
    when(() => settings.themeChoice).thenReturn(AppThemeChoice.system);
    final fake = FakeAppLockService(const AppLockState(isInitialized: true));
    addTearDown(fake.close);
    await sl.reset();
    sl.registerSingleton<AppLockService>(fake.mock);

    final router = GoRouter(
      routes: [GoRoute(path: '/', builder: (_, _) => const Text('home'))],
    );

    await tester.pumpWidget(
      Provider<SettingsService>.value(
        value: settings,
        child: App(router: router),
      ),
    );

    expect(
      find.descendant(
        of: find.byType(MaterialApp),
        matching: find.byType(AppLockGate),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(AppLockGate),
        matching: find.byType(Router<Object>),
      ),
      findsOneWidget,
    );
    expect(find.text('home'), findsOneWidget);
  });
}
