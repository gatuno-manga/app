import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/router.dart';
import 'package:gatuno/shared/presentation/error_screen.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import 'package:gatuno/core/di/injection.dart' as di;
import 'package:mocktail/mocktail.dart';
import 'package:gatuno/features/authentication/domain/use_cases/auth_service.dart';
import 'package:gatuno/features/users/data/models/user_model.dart';
import 'package:gatuno/shared/presentation/view_models/navigation_view_model.dart';

import 'package:provider/provider.dart';
import 'package:gatuno/features/home/presentation/view_models/home_view_model.dart';

class MockAuthService extends Mock implements AuthService {}

class MockHomeViewModel extends Mock implements HomeViewModel {}

class MockNavigationViewModel extends Mock implements NavigationViewModel {}

void main() {
  late MockAuthService mockAuthService;
  late MockHomeViewModel mockHomeViewModel;
  late MockNavigationViewModel mockNavigationViewModel;

  setUp(() async {
    await di.sl.reset();
    mockAuthService = MockAuthService();
    mockHomeViewModel = MockHomeViewModel();
    mockNavigationViewModel = MockNavigationViewModel();

    di.sl.registerSingleton<AuthService>(mockAuthService);
    di.sl.registerSingleton<HomeViewModel>(mockHomeViewModel);
    di.sl.registerFactory<NavigationViewModel>(() => mockNavigationViewModel);

    when(() => mockAuthService.authenticated).thenReturn(false);
    when(() => mockAuthService.isInitialized).thenReturn(true);
    when(
      () => mockAuthService.isAuthenticated(),
    ).thenAnswer((_) async => false);

    when(() => mockHomeViewModel.isAuthenticated).thenReturn(false);
    when(() => mockHomeViewModel.isInitialized).thenReturn(true);
    when(() => mockHomeViewModel.displayName).thenReturn(null);
    when(() => mockHomeViewModel.isLoadingFeatured).thenReturn(false);
    when(() => mockHomeViewModel.isLoadingContinueReading).thenReturn(false);
    when(() => mockHomeViewModel.isLoadingGrid).thenReturn(false);
    when(() => mockHomeViewModel.isLoadingRecentlyAdded).thenReturn(false);
    when(() => mockHomeViewModel.featuredBooks).thenReturn([]);
    when(() => mockHomeViewModel.continueReadingBooks).thenReturn([]);
    when(() => mockHomeViewModel.latestUpdatedBooks).thenReturn([]);
    when(() => mockHomeViewModel.recentlyAddedBooks).thenReturn([]);

    when(() => mockNavigationViewModel.isAuthenticated).thenReturn(false);
    when(() => mockNavigationViewModel.user).thenReturn(UserModel.guest);
  });

  tearDown(() async {
    await di.sl.reset();
  });

  testWidgets('appRouter should show ErrorScreen for non-existent route', (
    tester,
  ) async {
    final router = createAppRouter('/home');
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>.value(value: mockAuthService),
          ChangeNotifierProvider<HomeViewModel>.value(value: mockHomeViewModel),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );

    router.go('/non-existent');
    await tester.pumpAndSettle();

    expect(find.byType(ErrorScreen), findsOneWidget);
  });
}
