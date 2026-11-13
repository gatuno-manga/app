import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'presentation/views/settings_screen.dart';
import 'presentation/view_models/settings_view_model.dart';
import '../authentication/domain/use_cases/auth_service.dart';
import '../settings/domain/use_cases/settings_service.dart';
import '../reading/domain/use_cases/reader_preferences_service.dart';
import '../users/domain/use_cases/user_service.dart';
import '../users/presentation/views/me_screen.dart';
import '../users/presentation/view_models/me_view_model.dart';
import '../certificates/certificates_router.dart';
import 'presentation/views/mfa_settings_screen.dart';
import '../app_lock/presentation/views/app_lock_settings_screen.dart';
import '../../../core/di/injection.dart';

final GlobalKey<NavigatorState> settingsNavigatorKey =
    GlobalKey<NavigatorState>();

final StatefulShellBranch settingsBranch = StatefulShellBranch(
  navigatorKey: settingsNavigatorKey,
  routes: [
    GoRoute(
      path: '/settings',
      builder: (context, state) => MultiProvider(
        providers: [
          Provider<SettingsViewModel>(
            create: (_) => SettingsViewModel(
              settingsService: sl<SettingsService>(),
              authService: sl<AuthService>(),
              userService: sl<UserService>(),
            ),
          ),
          // Shared singleton owned by DI: provided, never disposed here.
          Provider<ReaderPreferencesService>.value(
            value: sl<ReaderPreferencesService>(),
          ),
        ],
        child: const SettingsPage(),
      ),
      routes: [
        ...certificatesRoutes,
        GoRoute(
          path: 'app-lock',
          builder: (context, state) => const AppLockSettingsPage(),
        ),
        GoRoute(
          path: 'mfa',
          redirect: (context, state) =>
              sl<AuthService>().authenticated ? null : '/auth/signin',
          builder: (context, state) => const MfaSettingsPage(),
        ),
        GoRoute(
          path:
              'profile', // Full path will be /settings/profile or use /users/me
          redirect: (context, state) {
            final authService = sl<AuthService>();
            if (!authService.authenticated) {
              return '/auth/signin';
            }
            return null;
          },
          builder: (context, state) => Provider<MeViewModel>(
            create: (_) => sl<MeViewModel>(),
            child: const MePage(),
          ),
        ),
      ],
    ),
  ],
);
