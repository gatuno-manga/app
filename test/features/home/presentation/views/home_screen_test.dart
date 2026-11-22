import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gatuno/features/home/presentation/components/organisms/featured_carousel.dart';
import 'package:gatuno/shared/components/molecules/app_profile_action.dart';
import 'package:gatuno/features/home/presentation/view_models/home_view_model.dart';
import 'package:gatuno/features/home/presentation/views/home_screen.dart';
import 'package:gatuno/features/books/domain/entities/book.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart';
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

    expect(find.byType(AppProfileAction), findsOneWidget);
    final avatar = tester.widget<AppAvatar>(find.byType(AppAvatar));
    expect(avatar.guest, isFalse);
    expect(avatar.imageUrl, 'http://x/a.webp');
  });

  testWidgets('shows the guest avatar icon for guests', (tester) async {
    await pumpHome(tester, HomeState.initial().copyWith(isInitialized: true));

    expect(find.byType(AppProfileAction), findsOneWidget);
    expect(tester.widget<AppAvatar>(find.byType(AppAvatar)).guest, isTrue);
  });

  testWidgets('keeps the avatar skeleton until auth is initialized', (
    tester,
  ) async {
    await pumpHome(tester, HomeState.initial());

    final avatar = tester.widget<AppAvatar>(find.byType(AppAvatar));
    expect(avatar.isLoading, isTrue);
    expect(avatar.guest, isFalse);
  });

  testWidgets('tapping the avatar opens the profile and settings screen', (
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

    await tester.tap(find.byType(AppProfileAction));
    await tester.pumpAndSettle();

    expect(find.text('Settings Page'), findsOneWidget);
  });

  testWidgets('tapping the guest icon opens the profile and settings screen', (
    tester,
  ) async {
    await pumpHome(tester, HomeState.initial().copyWith(isInitialized: true));

    await tester.tap(find.byType(AppProfileAction));
    await tester.pumpAndSettle();

    expect(find.text('Settings Page'), findsOneWidget);
  });

  group('links to Books', () {
    final withBooks = HomeState.initial().copyWith(
      isInitialized: true,
      latestUpdated: HomeBookSection(
        books: [Book(id: const BookId('a'), title: BookTitle('A'))],
      ),
    );

    testWidgets('View all on Latest Updates opens Books sorted', (
      tester,
    ) async {
      await pumpHome(tester, withBooks);
      await tester.tap(find.text('View all').first);
      await tester.pumpAndSettle();

      expect(find.textContaining('orderBy=updatedAt'), findsOneWidget);
      expect(find.textContaining('order=desc'), findsOneWidget);
      expect(find.textContaining('n='), findsOneWidget);
    });
  });

  group('offline', () {
    final nothingSaved = HomeState.initial().copyWith(
      isInitialized: true,
      isOffline: true,
      latestUpdated: const HomeBookSection(unavailableOffline: true),
      recentlyAdded: const HomeBookSection(unavailableOffline: true),
    );

    testWidgets('shows the offline empty view when nothing is saved', (
      tester,
    ) async {
      when(() => viewModel.retry()).thenAnswer((_) async {});
      await pumpHome(tester, nothingSaved);

      expect(find.byType(AppOfflineEmptyView), findsOneWidget);
      expect(find.byType(AppCtaCard), findsNothing);
      expect(find.byType(AppProfileAction), findsOneWidget);

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

    testWidgets('leaves out the header of a list with nothing saved', (
      tester,
    ) async {
      await pumpHome(
        tester,
        nothingSaved.copyWith(
          latestUpdated: HomeBookSection(
            books: [Book(id: const BookId('a'), title: BookTitle('A'))],
          ),
        ),
      );

      expect(find.byType(AppOfflineEmptyView), findsNothing);
      expect(find.text('Latest Updates'), findsOneWidget);
      expect(find.text('New on Gatuno'), findsNothing);
    });

    testWidgets('mounts the carousel only once it has books', (tester) async {
      await pumpHome(tester, HomeState.initial().copyWith(isInitialized: true));
      expect(find.byType(FeaturedCarousel), findsNothing);
    });

    testWidgets('shows the carousel with the latest books', (tester) async {
      await pumpHome(
        tester,
        HomeState.initial().copyWith(
          isInitialized: true,
          latestUpdated: HomeBookSection(
            books: [Book(id: const BookId('a'), title: BookTitle('A'))],
          ),
        ),
      );
      expect(find.byType(FeaturedCarousel), findsOneWidget);
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
