import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/app_theme_choice.dart';
import 'package:gatuno/core/theme/theme.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gatuno/features/reading/presentation/components/molecules/reader_dyslexia_preset_card.dart';
import 'package:gatuno/features/reading/data/data_sources/reader_preferences_storage.dart';
import 'package:gatuno/features/reading/domain/entities/reader_preferences.dart';
import 'package:gatuno/features/reading/domain/use_cases/reader_preferences_service.dart';
import 'package:gatuno/features/settings/presentation/views/settings_screen.dart';
import 'package:gatuno/features/settings/presentation/view_models/settings_view_model.dart';
import 'package:gatuno/features/settings/presentation/components/molecules/settings_profile_card.dart';
import 'package:gatuno/features/users/data/models/user_model.dart';
import 'package:gatuno/features/users/domain/use_cases/user_service.dart';
import 'package:gatuno/features/users/domain/value_objects/sensitive_content_weight.dart';
import 'package:gatuno/features/users/domain/value_objects/user_email.dart';
import 'package:gatuno/features/users/domain/value_objects/user_id.dart';
import 'package:gatuno/features/users/domain/value_objects/user_roles.dart';
import 'package:gatuno/shared/components/atoms/app_avatar.dart';
import 'package:gatuno/core/di/injection.dart';
import 'package:gatuno/features/app_lock/domain/use_cases/app_lock_service.dart';
import 'package:gatuno/features/app_lock/presentation/components/molecules/app_lock_settings_tile.dart';

import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_injection.dart';
import '../../../app_lock/helpers/app_lock_mocks.dart';

class MockUserService extends Mock implements UserService {}

void main() {
  late MockSettingsService mockSettingsService;
  late MockAuthService mockAuthService;
  late MockUserService mockUserService;
  late SettingsViewModel viewModel;
  late ReaderPreferencesService readerPreferences;

  Widget settingsPage() => MultiProvider(
    providers: [
      Provider<SettingsViewModel>.value(value: viewModel),
      Provider<ReaderPreferencesService>.value(value: readerPreferences),
    ],
    child: const SettingsPage(),
  );

  setUpAll(() => registerFallbackValue(AppThemeChoice.system));

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    readerPreferences = ReaderPreferencesService(ReaderPreferencesStorage());
    addTearDown(readerPreferences.dispose);
    mockSettingsService = MockSettingsService();
    mockAuthService = MockAuthService();
    mockUserService = MockUserService();

    when(
      () => mockSettingsService.settingsStream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockAuthService.authStateStream,
    ).thenAnswer((_) => const Stream.empty());

    when(() => mockSettingsService.apiUrl).thenReturn('http://test.com');
    when(() => mockSettingsService.sensitiveContentEnabled).thenReturn(false);
    when(
      () => mockSettingsService.themeChoice,
    ).thenReturn(AppThemeChoice.system);
    when(() => mockAuthService.authenticated).thenReturn(false);
    when(
      () => mockUserService.profileStream,
    ).thenAnswer((_) => Stream.value(UserModel.guest));

    viewModel = SettingsViewModel(
      settingsService: mockSettingsService,
      authService: mockAuthService,
      userService: mockUserService,
    );

    await initTestDI(
      settingsService: mockSettingsService,
      authService: mockAuthService,
    );
    final appLock = FakeAppLockService(
      const AppLockState(isSupported: true, isInitialized: true),
    );
    addTearDown(appLock.close);
    sl.registerLazySingleton<AppLockService>(() => appLock.mock);
  });

  testWidgets('SettingsPage shows the App lock entry in General', (
    tester,
  ) async {
    await tester.pumpApp(settingsPage(), theme: AppTheme.lightTheme);

    expect(find.byType(AppLockSettingsTile), findsOneWidget);
    expect(find.text('App lock'), findsOneWidget);
  });

  testWidgets('SettingsPage renders correctly for guest', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpApp(settingsPage(), theme: AppTheme.lightTheme);

    expect(find.text('Settings'), findsOneWidget);
    expect(find.byType(SettingsProfileCard), findsOneWidget);
    expect(find.text('Guest'), findsOneWidget);
    expect(find.text('API Base URL'), findsOneWidget);
    expect(find.text('Certificates'), findsNWidgets(2));
  });

  testWidgets('SettingsPage updates sensitive content toggle', (tester) async {
    when(
      () => mockSettingsService.setSensitiveContentEnabled(any()),
    ).thenAnswer((_) async {});

    await tester.pumpApp(settingsPage(), theme: AppTheme.lightTheme);

    await tester.tap(find.byType(Switch));
    await tester.pump();

    verify(
      () => mockSettingsService.setSensitiveContentEnabled(true),
    ).called(1);
  });

  testWidgets('SettingsPage can update API URL', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    when(
      () => mockSettingsService.validateApiUrl(any()),
    ).thenAnswer((_) async => true);
    when(() => mockSettingsService.setApiUrl(any())).thenAnswer((_) async {});

    await tester.pumpApp(settingsPage(), theme: AppTheme.lightTheme);

    await tester.enterText(find.byType(TextField).first, 'https://new-api.com');
    await tester.tap(find.text('Connect'));
    await tester.pump(); // Start loading
    await tester.pump(); // Finish loading

    verify(
      () => mockSettingsService.validateApiUrl('https://new-api.com'),
    ).called(1);
    verify(
      () => mockSettingsService.setApiUrl('https://new-api.com'),
    ).called(1);

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('API URL updated successfully'), findsOneWidget);
  });

  testWidgets('SettingsPage persists the picked theme', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    when(
      () => mockSettingsService.setThemeChoice(any()),
    ).thenAnswer((_) async {});

    await tester.pumpApp(settingsPage(), theme: AppTheme.lightTheme);

    await tester.tap(find.byKey(const ValueKey('theme-swatch-dracula')));
    await tester.pump();

    verify(
      () => mockSettingsService.setThemeChoice(AppThemeChoice.dracula),
    ).called(1);
  });

  testWidgets('SettingsPage shows the profile image on the card', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    when(() => mockAuthService.authenticated).thenReturn(true);
    when(() => mockUserService.profileStream).thenAnswer(
      (_) => Stream.value(
        UserModel(
          id: const UserId('1'),
          email: const UserEmail('maria@example.com'),
          roles: const UserRoles(['user']),
          maxWeightSensitiveContent: const SensitiveContentWeight(0),
          profilePictureUrl: 'http://x/a.webp',
        ),
      ),
    );
    viewModel = SettingsViewModel(
      settingsService: mockSettingsService,
      authService: mockAuthService,
      userService: mockUserService,
    );

    await tester.pumpApp(settingsPage(), theme: AppTheme.lightTheme);
    await tester.pump();

    expect(find.text('maria@example.com'), findsOneWidget);
    expect(
      tester.widget<AppAvatar>(find.byType(AppAvatar)).imageUrl,
      'http://x/a.webp',
    );
  });

  testWidgets('SettingsPage shows the guest card while the profile loads', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    when(() => mockAuthService.authenticated).thenReturn(true);
    viewModel = SettingsViewModel(
      settingsService: mockSettingsService,
      authService: mockAuthService,
      userService: mockUserService,
    );

    await tester.pumpApp(settingsPage(), theme: AppTheme.lightTheme);
    await tester.pump();

    // Signed in, profile not delivered yet: localized placeholder, never the
    // raw guest model.
    expect(find.text('Guest'), findsOneWidget);
    expect(find.text('guest'), findsNothing);
  });

  testWidgets('SettingsPage Reading section changes the shared reader '
      'preferences', (tester) async {
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpApp(settingsPage(), theme: AppTheme.lightTheme);

    expect(find.text('Reading'), findsOneWidget);
    expect(find.text('Reading theme'), findsOneWidget);
    expect(find.text('Font size (19px)'), findsOneWidget);

    await tester.tap(find.byTooltip('Increase font size'));
    await tester.pump();
    expect(readerPreferences.current.text.fontSize, 20);
    expect(find.text('Font size (20px)'), findsOneWidget);

    await tester.tap(find.text('Sepia'));
    await tester.pump();
    expect(readerPreferences.current.theme, ReaderTheme.sepia);
  });

  testWidgets('SettingsPage Reading section opens the accessibility sheet', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpApp(settingsPage(), theme: AppTheme.lightTheme);

    await tester.tap(find.text('Accessibility'));
    await tester.pumpAndSettle();
    expect(find.text('Dyslexia mode'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(ReaderDyslexiaPresetCard),
        matching: find.byType(Switch),
      ),
    );
    await tester.pumpAndSettle();
    expect(readerPreferences.current.dyslexiaMode, isTrue);
    expect(readerPreferences.current.theme, ReaderTheme.cream);
  });
}
