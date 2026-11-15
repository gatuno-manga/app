import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/app_theme_choice.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gatuno/features/settings/presentation/view_models/settings_view_model.dart';
import 'package:gatuno/features/settings/domain/use_cases/settings_service.dart';
import 'package:gatuno/features/downloads/domain/entities/download_totals.dart';
import 'package:gatuno/features/downloads/domain/repositories/download_service.dart';
import 'package:gatuno/features/authentication/domain/use_cases/auth_service.dart';
import 'package:gatuno/features/users/domain/use_cases/user_service.dart';
import 'package:gatuno/features/users/data/models/user_model.dart';
import 'package:gatuno/features/users/domain/value_objects/user_id.dart';
import 'package:gatuno/features/users/domain/value_objects/user_email.dart';
import 'package:gatuno/features/users/domain/value_objects/user_roles.dart';
import 'package:gatuno/features/users/domain/value_objects/sensitive_content_weight.dart';

class MockSettingsService extends Mock implements SettingsService {}

class MockAuthService extends Mock implements AuthService {}

class MockUserService extends Mock implements UserService {}

class MockDownloadService extends Mock implements DownloadService {}

void main() {
  late SettingsViewModel viewModel;
  late MockSettingsService mockSettingsService;
  late MockAuthService mockAuthService;
  late MockUserService mockUserService;
  late MockDownloadService mockDownloadService;

  SettingsViewModel buildViewModel() => SettingsViewModel(
    settingsService: mockSettingsService,
    authService: mockAuthService,
    userService: mockUserService,
    downloadService: mockDownloadService,
  );

  setUpAll(() => registerFallbackValue(AppThemeChoice.system));

  setUp(() {
    mockSettingsService = MockSettingsService();
    mockAuthService = MockAuthService();
    mockUserService = MockUserService();
    mockDownloadService = MockDownloadService();

    // When listening, we need to stub streams
    when(
      () => mockSettingsService.settingsStream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockAuthService.authStateStream,
    ).thenAnswer((_) => const Stream.empty());

    // Setup mock returns BEFORE init
    when(() => mockSettingsService.apiUrl).thenReturn('http://test.com');
    when(() => mockSettingsService.sensitiveContentEnabled).thenReturn(true);
    when(
      () => mockSettingsService.themeChoice,
    ).thenReturn(AppThemeChoice.system);
    when(() => mockAuthService.authenticated).thenReturn(true);
    when(
      () => mockUserService.profileStream,
    ).thenAnswer((_) => Stream.value(UserModel.guest));

    viewModel = buildViewModel();
  });

  group('SettingsViewModel', () {
    test('should expose values from services', () async {
      final user = UserModel(
        id: const UserId('1'),
        email: const UserEmail('test@test.com'),
        roles: const UserRoles(['user']),
        maxWeightSensitiveContent: const SensitiveContentWeight(0),
      );

      // User was mocked to guest in setup, let's override and re-init for this test
      when(
        () => mockUserService.profileStream,
      ).thenAnswer((_) => Stream.value(user));
      viewModel = buildViewModel();
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.apiUrl, 'http://test.com');
      expect(viewModel.state.sensitiveContentEnabled, isTrue);
      expect(viewModel.state.isAuthenticated, isTrue);
      expect(viewModel.state.user, equals(user));
    });

    test('setSensitiveContentEnabled should call service', () async {
      when(
        () => mockSettingsService.setSensitiveContentEnabled(any()),
      ).thenAnswer((_) async {});

      await viewModel.setSensitiveContentEnabled(false);

      verify(
        () => mockSettingsService.setSensitiveContentEnabled(false),
      ).called(1);
    });

    group('updateApiUrl', () {
      late List<DownloadTotals?> asked;
      late bool answer;

      Future<ApiUrlUpdateResult> save(String url) => viewModel.updateApiUrl(
        url,
        confirmServerChange: (totals) async {
          asked.add(totals);
          return answer;
        },
      );

      setUp(() {
        asked = [];
        answer = true;
        when(
          () => mockSettingsService.validateApiUrl(any()),
        ).thenAnswer((_) async => true);
        when(
          () => mockSettingsService.setApiUrl(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockSettingsService.isDifferentServer(any()),
        ).thenReturn(true);
        when(
          () => mockDownloadService.totals(),
        ).thenAnswer((_) async => DownloadTotals.empty);
      });

      test('saves a different server without asking when there are no '
          'downloads', () async {
        final result = await save('http://valid.com/');

        expect(result, ApiUrlUpdateResult.saved);
        expect(asked, isEmpty);
        verify(
          () => mockSettingsService.validateApiUrl('http://valid.com/'),
        ).called(1);
        verify(
          () => mockSettingsService.setApiUrl('http://valid.com'),
        ).called(1);
        expect(viewModel.state.isLoading, isFalse);
      });

      test('asks with the totals when there are downloads, and a cancel '
          'keeps the server', () async {
        const totals = DownloadTotals(chapters: 12, bytes: 340 * 1024 * 1024);
        when(
          () => mockDownloadService.totals(),
        ).thenAnswer((_) async => totals);
        answer = false;

        final result = await save('http://other.com');

        expect(result, ApiUrlUpdateResult.cancelled);
        expect(asked, [totals]);
        verifyNever(() => mockSettingsService.setApiUrl(any()));
        expect(viewModel.state.isLoading, isFalse);
      });

      test('a confirm with downloads switches the server', () async {
        const totals = DownloadTotals(chapters: 1, bytes: 10);
        when(
          () => mockDownloadService.totals(),
        ).thenAnswer((_) async => totals);

        final result = await save('http://other.com');

        expect(result, ApiUrlUpdateResult.saved);
        expect(asked, [totals]);
        verify(
          () => mockSettingsService.setApiUrl('http://other.com'),
        ).called(1);
      });

      test('the same server neither counts downloads nor asks', () async {
        when(
          () => mockSettingsService.isDifferentServer('http://test.com'),
        ).thenReturn(false);

        final result = await save('http://test.com/');

        expect(result, ApiUrlUpdateResult.saved);
        expect(asked, isEmpty);
        verifyNever(() => mockDownloadService.totals());
        verify(
          () => mockSettingsService.setApiUrl('http://test.com'),
        ).called(1);
      });

      test('an invalid URL fails without asking', () async {
        when(
          () => mockSettingsService.validateApiUrl(any()),
        ).thenAnswer((_) async => false);

        final result = await save('http://invalid.com');

        expect(result, ApiUrlUpdateResult.failed);
        expect(asked, isEmpty);
        verifyNever(() => mockDownloadService.totals());
        verifyNever(() => mockSettingsService.setApiUrl(any()));
      });

      test(
        'asks without numbers when the downloads cannot be counted',
        () async {
          when(() => mockDownloadService.totals()).thenThrow(StateError('db'));
          answer = false;

          final result = await save('http://other.com');

          expect(result, ApiUrlUpdateResult.cancelled);
          expect(asked, [null]);
          verifyNever(() => mockSettingsService.setApiUrl(any()));
        },
      );

      test('a failed save is reported as failed', () async {
        when(
          () => mockSettingsService.setApiUrl(any()),
        ).thenThrow(StateError('disk'));

        final result = await save('http://other.com');

        expect(result, ApiUrlUpdateResult.failed);
        expect(viewModel.state.isLoading, isFalse);
      });
    });

    test('follows the profile stream', () async {
      final profiles = StreamController<UserModel>();
      addTearDown(profiles.close);
      when(
        () => mockUserService.profileStream,
      ).thenAnswer((_) => profiles.stream);
      viewModel = buildViewModel();
      final fresh = UserModel(
        id: const UserId('1'),
        email: const UserEmail('test@test.com'),
        roles: const UserRoles(['user']),
        maxWeightSensitiveContent: const SensitiveContentWeight(0),
        profilePictureUrl: 'http://x/new.webp',
      );

      profiles.add(fresh);
      await Future<void>.delayed(Duration.zero);
      expect(viewModel.state.user, same(fresh));

      profiles.add(UserModel.guest);
      await Future<void>.delayed(Duration.zero);
      expect(viewModel.state.user, same(UserModel.guest));
    });

    test('setThemeChoice swallows and logs a failed write', () async {
      when(
        () => mockSettingsService.setThemeChoice(any()),
      ).thenThrow(Exception('disk full'));

      await expectLater(
        viewModel.setThemeChoice(AppThemeChoice.slate),
        completes,
      );
    });
  });
}
