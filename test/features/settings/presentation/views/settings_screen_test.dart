import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/app_theme_choice.dart';
import 'package:gatuno/core/theme/theme.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gatuno/features/reading/presentation/components/organisms/reader_dyslexia_preset_card.dart';
import 'package:gatuno/features/reading/data/data_sources/reader_preferences_storage.dart';
import 'package:gatuno/features/reading/domain/entities/reader_preferences.dart';
import 'package:gatuno/features/reading/domain/use_cases/reader_preferences_service.dart';
import 'package:gatuno/features/downloads/domain/entities/download_totals.dart';
import 'package:gatuno/features/downloads/domain/repositories/download_service.dart';
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
import 'package:gatuno/shared/components/organisms/app_confirm_dialog.dart';
import 'package:gatuno/core/di/injection.dart';
import 'package:gatuno/features/app_lock/domain/use_cases/app_lock_service.dart';
import 'package:gatuno/features/app_lock/presentation/components/molecules/app_lock_settings_tile.dart';

import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_injection.dart';
import '../../../app_lock/helpers/app_lock_mocks.dart';

class MockUserService extends Mock implements UserService {}

class MockDownloadService extends Mock implements DownloadService {}

void main() {
  late MockSettingsService mockSettingsService;
  late MockAuthService mockAuthService;
  late MockUserService mockUserService;
  late MockDownloadService mockDownloadService;
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
    mockDownloadService = MockDownloadService();
    when(
      () => mockDownloadService.totals(),
    ).thenAnswer((_) async => DownloadTotals.empty);
    when(() => mockSettingsService.isDifferentServer(any())).thenReturn(true);

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
      downloadService: mockDownloadService,
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

    expect(find.byType(AppConfirmDialog), findsNothing);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('API URL updated successfully'), findsOneWidget);
  });

  group('server change with downloads', () {
    const totals = DownloadTotals(chapters: 34, bytes: 1288490189); // 1.2 GB

    Future<void> saveOtherServer(WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      when(
        () => mockSettingsService.validateApiUrl(any()),
      ).thenAnswer((_) async => true);
      when(() => mockSettingsService.setApiUrl(any())).thenAnswer((_) async {});

      await tester.pumpApp(settingsPage(), theme: AppTheme.lightTheme);
      await tester.enterText(find.byType(TextField).first, 'https://other.com');
      await tester.tap(find.text('Connect'));
      await tester.pumpAndSettle();
    }

    Future<void> tapAndClose(WidgetTester tester, String label) async {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }

    testWidgets('asks with the chapter count and size', (tester) async {
      when(() => mockDownloadService.totals()).thenAnswer((_) async => totals);

      await saveOtherServer(tester);

      expect(find.byType(AppConfirmDialog), findsOneWidget);
      expect(find.text('Change server?'), findsOneWidget);
      expect(
        find.text(
          'The 34 chapters in your downloads (1.2\u00A0GB) will be deleted, '
          'and the offline library saved on this device will be cleared.',
        ),
        findsOneWidget,
      );
      expect(find.text('Switch and delete'), findsOneWidget);
      verifyNever(() => mockSettingsService.setApiUrl(any()));
    });

    testWidgets('formats a large chapter count for the locale', (tester) async {
      when(() => mockDownloadService.totals()).thenAnswer(
        (_) async => const DownloadTotals(chapters: 1234, bytes: 1024),
      );

      await saveOtherServer(tester);

      expect(find.textContaining('The 1,234 chapters'), findsOneWidget);
    });

    testWidgets('cancel keeps the server and shows no message', (tester) async {
      when(() => mockDownloadService.totals()).thenAnswer((_) async => totals);

      await saveOtherServer(tester);
      await tapAndClose(tester, 'Cancel');

      expect(find.byType(AppConfirmDialog), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
      verifyNever(() => mockSettingsService.setApiUrl(any()));
    });

    testWidgets('confirm switches the server', (tester) async {
      when(() => mockDownloadService.totals()).thenAnswer((_) async => totals);

      await saveOtherServer(tester);
      await tapAndClose(tester, 'Switch and delete');

      expect(find.byType(AppConfirmDialog), findsNothing);
      verify(
        () => mockSettingsService.setApiUrl('https://other.com'),
      ).called(1);
      expect(find.text('API URL updated successfully'), findsOneWidget);
    });

    testWidgets('asks without numbers when the downloads cannot be counted', (
      tester,
    ) async {
      when(() => mockDownloadService.totals()).thenThrow(StateError('db'));

      await saveOtherServer(tester);

      expect(
        find.text(
          'The downloads and the offline library saved on this device will '
          'be deleted.',
        ),
        findsOneWidget,
      );
    });
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
      downloadService: mockDownloadService,
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
      downloadService: mockDownloadService,
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
