import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gatuno/features/home/presentation/components/molecules/login_icon.dart';
import 'package:gatuno/features/home/presentation/components/molecules/user_profile_icon.dart';
import 'package:gatuno/features/home/presentation/view_models/home_view_model.dart';
import 'package:gatuno/features/home/presentation/views/home_screen.dart';
import 'package:gatuno/features/users/data/models/user_model.dart';
import 'package:gatuno/features/users/domain/value_objects/sensitive_content_weight.dart';
import 'package:gatuno/features/users/domain/value_objects/user_display_name.dart';
import 'package:gatuno/features/users/domain/value_objects/user_email.dart';
import 'package:gatuno/features/users/domain/value_objects/user_id.dart';
import 'package:gatuno/features/users/domain/value_objects/user_roles.dart';
import 'package:gatuno/shared/components/atoms/app_avatar.dart';
import 'package:gatuno/shared/components/atoms/app_button.dart';
import 'package:gatuno/shared/components/molecules/app_cta_card.dart';
import 'package:gatuno/shared/components/molecules/app_offline_empty_view.dart';

import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_injection.dart';

void main() {
  late MockHomeViewModel viewModel;

  final maria = UserModel(
    id: const UserId('1'),
    email: const UserEmail('maria@example.com'),
    roles: const UserRoles(['user']),
    maxWeightSensitiveContent: const SensitiveContentWeight(0),
    name: const UserDisplayName('Maria'),
    profilePictureUrl: 'http://x/a.webp',
  );

  Future<void> pumpHome(WidgetTester tester, HomeState state) async {
    when(() => viewModel.stateStream).thenAnswer((_) => const Stream.empty());
    when(() => viewModel.state).thenReturn(state);
    await tester.pumpApp(const HomePage());
  }

  setUp(() async {
    viewModel = MockHomeViewModel();
    await initTestDI(homeViewModel: viewModel);
  });

  testWidgets('shows the avatar with the profile image when signed in', (
    tester,
  ) async {
    await pumpHome(
      tester,
      HomeState.initial().copyWith(
        isInitialized: true,
        isAuthenticated: true,
        user: maria,
      ),
    );

    expect(find.byType(UserProfileIcon), findsOneWidget);
    expect(find.byType(LoginIcon), findsNothing);
    expect(
      tester.widget<AppAvatar>(find.byType(AppAvatar)).imageUrl,
      'http://x/a.webp',
    );
  });

  testWidgets('shows the login icon for guests', (tester) async {
    await pumpHome(tester, HomeState.initial().copyWith(isInitialized: true));

    expect(find.byType(LoginIcon), findsOneWidget);
    expect(find.byType(UserProfileIcon), findsNothing);
  });

  testWidgets('shows no header action until auth is initialized', (
    tester,
  ) async {
    await pumpHome(tester, HomeState.initial());

    expect(find.byType(LoginIcon), findsNothing);
    expect(find.byType(UserProfileIcon), findsNothing);
  });

  testWidgets('tapping the avatar opens the profile', (tester) async {
    await pumpHome(
      tester,
      HomeState.initial().copyWith(
        isInitialized: true,
        isAuthenticated: true,
        user: maria,
      ),
    );

    await tester.tap(find.byType(UserProfileIcon));
    await tester.pumpAndSettle();

    expect(find.text('Profile Page'), findsOneWidget);
  });

  testWidgets('tapping the login icon opens sign in', (tester) async {
    await pumpHome(tester, HomeState.initial().copyWith(isInitialized: true));

    await tester.tap(find.byType(LoginIcon));
    await tester.pumpAndSettle();

    expect(find.text('Signin Page'), findsOneWidget);
  });

  group('offline', () {
    final nothingSaved = HomeState.initial().copyWith(
      isInitialized: true,
      isOffline: true,
      isLoadingFeatured: false,
      isLoadingGrid: false,
      isLoadingRecentlyAdded: false,
      latestUnavailableOffline: true,
      recentUnavailableOffline: true,
    );

    testWidgets('shows the offline empty view when nothing is saved', (
      tester,
    ) async {
      when(() => viewModel.retry()).thenAnswer((_) async {});
      await pumpHome(tester, nothingSaved);

      expect(find.byType(AppOfflineEmptyView), findsOneWidget);
      expect(find.byType(AppCtaCard), findsNothing);
      expect(find.byType(LoginIcon), findsOneWidget);

      await tester.tap(find.byType(AppButton));
      verify(() => viewModel.retry()).called(1);
    });

    testWidgets('shows retry progress', (tester) async {
      await pumpHome(tester, nothingSaved.copyWith(isRetrying: true));

      expect(
        tester
            .widget<AppOfflineEmptyView>(find.byType(AppOfflineEmptyView))
            .isRetrying,
        isTrue,
      );
    });

    testWidgets('disables the call to action with a note', (tester) async {
      await pumpHome(
        tester,
        HomeState.initial().copyWith(isInitialized: true, isOffline: true),
      );
      await tester.scrollUntilVisible(
        find.byType(AppCtaCard),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      final cta = tester.widget<AppCtaCard>(find.byType(AppCtaCard));
      expect(cta.onPressed, isNull);
      expect(find.text("Available when you're back online."), findsOneWidget);
      expect(find.byType(AppOfflineEmptyView), findsNothing);
    });

    testWidgets('enables the call to action online', (tester) async {
      await pumpHome(tester, HomeState.initial().copyWith(isInitialized: true));

      final cta = tester.widget<AppCtaCard>(find.byType(AppCtaCard));
      expect(cta.onPressed, isNotNull);
      expect(cta.note, isNull);
    });
  });
}
