import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/di/injection.dart';
import 'package:gatuno/core/theme/app_theme_choice.dart';
import 'package:gatuno/core/theme/theme.dart';
import 'package:gatuno/features/app_lock/domain/use_cases/app_lock_service.dart';
import 'package:gatuno/features/settings/domain/use_cases/settings_service.dart';
import 'package:gatuno/main.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'features/app_lock/helpers/app_lock_mocks.dart';
import 'helpers/test_injection.dart';

void main() {
  testWidgets('MaterialApp follows the persisted theme choice', (tester) async {
    final service = MockSettingsService();
    final controller = StreamController<SettingsState>.broadcast();
    addTearDown(controller.close);
    when(() => service.settingsStream).thenAnswer((_) => controller.stream);
    when(() => service.themeChoice).thenReturn(AppThemeChoice.system);

    final fake = FakeAppLockService(const AppLockState(isInitialized: true));
    addTearDown(fake.close);
    await sl.reset();
    sl.registerSingleton<AppLockService>(fake.mock);

    final router = GoRouter(
      routes: [GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink())],
    );

    await tester.pumpWidget(
      Provider<SettingsService>.value(
        value: service,
        child: App(router: router),
      ),
    );
    var app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.system);

    controller.add(SettingsState(themeChoice: AppThemeChoice.dracula));
    await tester.pump();

    app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(app.darkTheme, AppTheme.draculaTheme);
  });
}
