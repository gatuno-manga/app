import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/shared/components/organisms/navigation_shell.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import 'package:gatuno/features/authentication/domain/use_cases/auth_service.dart';
import 'package:gatuno/core/router/router_keys.dart';
import 'package:gatuno/features/home/presentation/view_models/home_view_model.dart';
import 'package:gatuno/shared/presentation/view_models/navigation_view_model.dart';
import '../../../helpers/test_injection.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockHomeViewModel mockHomeViewModel;
  late MockNavigationViewModel mockNavigationViewModel;

  setUp(() async {
    mockAuthService = MockAuthService();
    mockHomeViewModel = MockHomeViewModel();
    mockNavigationViewModel = MockNavigationViewModel();

    await initTestDI(
      authService: mockAuthService,
      homeViewModel: mockHomeViewModel,
      navigationViewModel: mockNavigationViewModel,
    );

    when(() => mockAuthService.authenticated).thenReturn(false);
    when(() => mockAuthService.isInitialized).thenReturn(true);
    when(
      () => mockAuthService.isAuthenticated(),
    ).thenAnswer((_) async => false);

    when(
      () => mockHomeViewModel.stateStream,
    ).thenAnswer((_) => const Stream.empty());
    when(() => mockHomeViewModel.state).thenReturn(HomeState.initial());
  });

  Future<void> pumpNavigationShell(WidgetTester tester) async {
    final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/home',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return NavigationShell(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const Text('Home Content'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/library',
                  builder: (context, state) => const Text('Library Content'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/books',
                  builder: (context, state) => const Text('Books Content'),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/auth/signin',
          builder: (context, state) => const Text('Signin Page'),
        ),
      ],
    );

    await tester.pumpWidget(
      Provider<AuthService>.value(
        value: mockAuthService,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('NavigationShell renders bottom navigation items', (
    WidgetTester tester,
  ) async {
    when(
      () => mockNavigationViewModel.stateStream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockNavigationViewModel.state,
    ).thenReturn(NavigationState.initial());
    await pumpNavigationShell(tester);

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Books'), findsOneWidget);
    expect(find.text('Home Content'), findsOneWidget);
  });

  testWidgets('NavigationShell navigates between branches', (
    WidgetTester tester,
  ) async {
    when(
      () => mockNavigationViewModel.stateStream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockNavigationViewModel.state,
    ).thenReturn(NavigationState.initial());
    await pumpNavigationShell(tester);

    await tester.tap(find.text('Books'));
    await tester.pumpAndSettle();
    expect(find.text('Books Content'), findsOneWidget);

    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    expect(find.text('Library Content'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Home Content'), findsOneWidget);
  });

  testWidgets('NavigationShell shows the offline banner while offline', (
    WidgetTester tester,
  ) async {
    when(
      () => mockNavigationViewModel.stateStream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockNavigationViewModel.state,
    ).thenReturn(NavigationState.initial().copyWith(isOffline: true));
    await pumpNavigationShell(tester);

    expect(find.text('Offline: showing saved data'), findsOneWidget);
    expect(find.text('Home Content'), findsOneWidget);
  });
}
