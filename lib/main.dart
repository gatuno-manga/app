import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/app_theme_choice.dart';
import 'core/theme/theme.dart';
import 'core/di/injection.dart';
import 'features/app_lock/domain/use_cases/app_lock_service.dart';
import 'features/app_lock/presentation/components/organisms/app_lock_gate.dart';
import 'features/authentication/domain/use_cases/auth_service.dart';
import 'features/settings/domain/use_cases/settings_service.dart';
import 'shared/utils/app_activity_observer.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDI();

  final settingsService = sl<SettingsService>();
  final initialLocation = settingsService.apiUrl == null ? '/welcome' : '/home';
  final router = createAppRouter(initialLocation);

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: sl<AuthService>()),
        Provider.value(value: settingsService),
        Provider.value(value: sl<AppLockService>()),
      ],
      child: App(router: router),
    ),
  );
}

class App extends StatelessWidget {
  final GoRouter router;
  const App({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    final settingsService = context.read<SettingsService>();
    return AppActivityObserver(
      onIdle: () => context.read<AuthService>().pauseRefresh(),
      onInteraction: () => context.read<AuthService>().evaluateTokenState(),
      child: StreamBuilder<AppThemeChoice>(
        stream: settingsService.settingsStream
            .map((state) => state.themeChoice)
            .distinct(),
        initialData: settingsService.themeChoice,
        builder: (context, snapshot) {
          final choice = snapshot.data!;
          return MaterialApp.router(
            title: 'Gatuno',
            theme: AppTheme.lightTheme,
            darkTheme: choice.darkTheme,
            themeMode: choice.themeMode,
            routerConfig: router,
            // Above the router so the route stack survives a lock, below the
            // localizations so the cover and prompt reason are translated.
            builder: (context, child) => AppLockGate(
              service: context.read<AppLockService>(),
              child: child!,
            ),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('pt')],
          );
        },
      ),
    );
  }
}
