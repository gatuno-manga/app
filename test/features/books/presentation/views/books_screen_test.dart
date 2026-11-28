import 'package:flutter/material.dart';
import 'package:gatuno/shared/domain/value_objects/positive_int.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart';
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/entities/book.dart';
import 'package:gatuno/features/books/domain/entities/book_page_options.dart';
import 'package:gatuno/features/books/domain/entities/books_view_preferences.dart';
import 'package:gatuno/features/books/presentation/view_models/books_view_model.dart';
import 'package:gatuno/features/books/presentation/components/organisms/books_view_toolbar.dart';
import 'package:gatuno/features/books/presentation/components/molecules/books_view_mode_selector.dart';
import 'package:gatuno/features/books/presentation/views/books_screen.dart';
import 'package:gatuno/shared/components/atoms/app_load_more_footer.dart';
import 'package:gatuno/shared/components/molecules/app_offline_empty_view.dart';
import 'package:gatuno/shared/components/molecules/pagination.dart';
import 'package:gatuno/features/books/presentation/components/molecules/books_offline_notice.dart';
import 'package:gatuno/features/books/books_launch_intent.dart';
import 'package:go_router/go_router.dart';
import 'package:gatuno/core/di/injection.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import 'package:gatuno/shared/components/atoms/app_avatar.dart';
import 'package:gatuno/shared/components/molecules/app_profile_action.dart';
import 'package:gatuno/shared/presentation/view_models/navigation_view_model.dart';
import 'package:gatuno/features/users/data/models/user_model.dart';
import 'package:gatuno/features/users/domain/value_objects/sensitive_content_weight.dart';
import 'package:gatuno/features/users/domain/value_objects/user_email.dart';
import 'package:gatuno/features/users/domain/value_objects/user_id.dart';
import 'package:gatuno/features/users/domain/value_objects/user_roles.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_injection.dart';

class MockBooksViewModel extends Mock implements BooksViewModel {}

void main() {
  late MockBooksViewModel mockViewModel;

  setUpAll(() {
    registerFallbackValue(BookId('dummy'));
    registerFallbackValue(const BookPageOptions());
    registerFallbackValue(SortOrder.asc);
  });

  late StreamController<BooksState> stateController;

  setUp(() async {
    await initTestDI();
    mockViewModel = MockBooksViewModel();

    // Default mock behavior
    final mockState = BooksState.initial();
    stateController = StreamController<BooksState>.broadcast();
    stateController.add(mockState);
    when(() => mockViewModel.state).thenReturn(mockState);
    when(
      () => mockViewModel.stateStream,
    ).thenAnswer((_) => stateController.stream);
    when(() => mockViewModel.isLoading).thenReturn(false);
    when(() => mockViewModel.error).thenReturn(null);
    when(
      () => mockViewModel.preferences,
    ).thenReturn(const BooksViewPreferences());
    when(() => mockViewModel.hasMore).thenReturn(false);
    when(() => mockViewModel.isLoadingMore).thenReturn(false);
    when(() => mockViewModel.isOffline).thenReturn(false);
    when(() => mockViewModel.isCacheList).thenReturn(false);
    when(() => mockViewModel.isPagingPaused).thenReturn(false);
    when(() => mockViewModel.isOfflineMiss).thenReturn(false);
    when(() => mockViewModel.isRefreshing).thenReturn(false);
    when(() => mockViewModel.refresh()).thenAnswer((_) async {});
    when(() => mockViewModel.loadMore()).thenAnswer((_) async {});
    const options = BookPageOptions();
    when(() => mockViewModel.options).thenReturn(options);
    when(() => mockViewModel.bookList).thenReturn(null);
    when(
      () => mockViewModel.fetchBooks(append: any(named: 'append')),
    ).thenAnswer((_) async {});
  });

  tearDown(() {
    stateController.close();
  });

  Widget createWidgetUnderTest() {
    return Provider<BooksViewModel>.value(
      value: mockViewModel,
      child: const BooksPage(),
    );
  }

  testWidgets('shows SnackBar when error occurs and there is content', (
    tester,
  ) async {
    final bookList = BookList(
      data: [
        Book(
          id: const BookId('1'),
          title: const BookTitle('Test Book'),
          type: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ],
      total: const PositiveInt(1),
      page: const PositiveInt(1),
      limit: const PositiveInt(20),
      totalPages: const PositiveInt(1),
    );

    // Initial state with content
    final mockState2 = BooksState.initial().copyWith(bookList: () => bookList);
    stateController.add(mockState2);
    when(() => mockViewModel.state).thenReturn(mockState2);
    when(() => mockViewModel.bookList).thenReturn(bookList);
    when(() => mockViewModel.error).thenReturn(null);

    await tester.pumpApp(createWidgetUnderTest());

    // Verify initial state
    expect(find.text('Test Book'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);

    // Trigger error
    final mockState3 = mockState2.copyWith(error: () => 'Some error occurred');
    stateController.add(mockState3);
    when(() => mockViewModel.state).thenReturn(mockState3);
    when(() => mockViewModel.error).thenReturn('Some error occurred');

    await tester.pump(); // Trigger build
    await tester.pumpAndSettle(); // Show snackbar

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Some error occurred'), findsOneWidget);

    verify(() => mockViewModel.clearError()).called(1);
  });

  testWidgets(
    'shows full screen error when error occurs and there is NO content',
    (tester) async {
      final mockState4 = BooksState.initial().copyWith(
        error: () => 'Initial load failed',
      );
      stateController.add(mockState4);
      when(() => mockViewModel.state).thenReturn(mockState4);
      when(() => mockViewModel.bookList).thenReturn(null);
      when(() => mockViewModel.error).thenReturn('Initial load failed');

      await tester.pumpApp(createWidgetUnderTest());

      expect(find.text('Initial load failed'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
    },
  );

  BookList listOf(int count, {int totalPages = 1, int page = 1}) {
    return BookList(
      data: [
        for (var i = 0; i < count; i++)
          Book(id: BookId('$i'), title: BookTitle('Book $i')),
      ],
      total: PositiveInt(count),
      page: PositiveInt(page),
      limit: const PositiveInt(20),
      totalPages: PositiveInt(totalPages),
    );
  }

  void stubState(BooksState state) {
    stateController.add(state);
    when(() => mockViewModel.state).thenReturn(state);
    when(() => mockViewModel.bookList).thenReturn(state.bookList);
    when(() => mockViewModel.error).thenReturn(state.error);
    when(() => mockViewModel.isLoading).thenReturn(state.isLoading);
    when(() => mockViewModel.preferences).thenReturn(state.preferences);
    when(() => mockViewModel.hasMore).thenReturn(state.hasMore);
    when(() => mockViewModel.isLoadingMore).thenReturn(state.isLoadingMore);
    when(() => mockViewModel.options).thenReturn(state.options);
    when(() => mockViewModel.isOffline).thenReturn(state.isOffline);
    when(() => mockViewModel.isCacheList).thenReturn(state.isCacheList);
    when(() => mockViewModel.isPagingPaused).thenReturn(state.isPagingPaused);
    when(() => mockViewModel.isOfflineMiss).thenReturn(state.isOfflineMiss);
    when(() => mockViewModel.isRefreshing).thenReturn(state.isRefreshing);
  }

  group('view options', () {
    testWidgets('shows the view toolbar with the mode selector', (
      tester,
    ) async {
      stubState(BooksState.initial().copyWith(bookList: () => listOf(1)));

      await tester.pumpApp(createWidgetUnderTest());

      expect(find.byType(BooksViewToolbar), findsOneWidget);
      expect(find.byType(BooksViewModeSelector), findsOneWidget);
    });

    testWidgets('hides the pagination bar in infinite mode', (tester) async {
      stubState(
        BooksState.initial().copyWith(
          bookList: () => listOf(1, totalPages: 5),
          preferences: const BooksViewPreferences(
            navigation: BooksNavigationMode.infinite,
          ),
        ),
      );

      await tester.pumpApp(createWidgetUnderTest());

      expect(find.byType(Pagination), findsNothing);
    });

    testWidgets('shows the pagination bar in pages mode', (tester) async {
      stubState(
        BooksState.initial().copyWith(
          bookList: () => listOf(1, totalPages: 5),
          preferences: const BooksViewPreferences(
            navigation: BooksNavigationMode.pages,
          ),
        ),
      );

      await tester.pumpApp(createWidgetUnderTest());

      expect(find.byType(Pagination), findsOneWidget);
    });

    testWidgets('shows the load-more footer while appending', (tester) async {
      stubState(
        BooksState.initial().copyWith(
          bookList: () => listOf(1, totalPages: 5),
          isLoading: true,
          isLoadingMore: true,
          preferences: const BooksViewPreferences(
            navigation: BooksNavigationMode.infinite,
            columns: 4,
          ),
        ),
      );

      await tester.pumpApp(createWidgetUnderTest());

      expect(find.byType(AppLoadMoreFooter), findsOneWidget);
    });

    testWidgets('hides the load-more footer during a refresh', (tester) async {
      stubState(
        BooksState.initial().copyWith(
          bookList: () => listOf(1, totalPages: 5),
          isLoading: true,
          preferences: const BooksViewPreferences(columns: 4),
        ),
      );

      await tester.pumpApp(createWidgetUnderTest());

      expect(find.byType(AppLoadMoreFooter), findsNothing);
    });

    testWidgets('scrolling to the end asks the view model for more', (
      tester,
    ) async {
      stubState(
        BooksState.initial().copyWith(
          bookList: () => listOf(30, totalPages: 5),
          preferences: const BooksViewPreferences(columns: 4),
        ),
      );

      await tester.pumpApp(createWidgetUnderTest());
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -6000));
      await tester.pump();

      verify(() => mockViewModel.loadMore()).called(1);
    });

    testWidgets('pull-to-refresh fetches again', (tester) async {
      stubState(BooksState.initial().copyWith(bookList: () => listOf(1)));

      await tester.pumpApp(createWidgetUnderTest());
      await tester.fling(
        find.byType(CustomScrollView),
        const Offset(0, 400),
        1000,
      );
      await tester.pumpAndSettle();

      verify(() => mockViewModel.refresh()).called(1);
    });

    testWidgets('tapping a layout segment calls setLayoutMode', (tester) async {
      stubState(BooksState.initial().copyWith(bookList: () => listOf(1)));

      await tester.pumpApp(createWidgetUnderTest());
      await tester.tap(find.byTooltip('Covers'));

      verify(
        () => mockViewModel.setLayoutMode(BooksLayoutMode.cover),
      ).called(1);
    });

    testWidgets('app bar no longer has the layout toggle', (tester) async {
      stubState(BooksState.initial().copyWith(bookList: () => listOf(1)));

      await tester.pumpApp(createWidgetUnderTest());

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.view_list),
        ),
        findsNothing,
      );
    });
  });

  group('offline', () {
    // Four columns keep the end of the list on the test screen.
    const infinite = BooksViewPreferences(
      navigation: BooksNavigationMode.infinite,
      columns: 4,
    );
    const pages = BooksViewPreferences(navigation: BooksNavigationMode.pages);

    testWidgets('a cache list shows the offline notice', (tester) async {
      stubState(
        BooksState.initial().copyWith(
          bookList: () => listOf(1),
          source: () => BooksListSource.cache,
          isOffline: true,
        ),
      );

      await tester.pumpApp(createWidgetUnderTest());

      expect(find.byType(BooksOfflineNotice), findsOneWidget);
      expect(
        find.textContaining('Showing books saved on this device.'),
        findsOneWidget,
      );
    });

    testWidgets('a server list shows no offline notice', (tester) async {
      stubState(
        BooksState.initial().copyWith(
          bookList: () => listOf(1),
          source: () => BooksListSource.server,
          isOffline: true,
        ),
      );

      await tester.pumpApp(createWidgetUnderTest());

      expect(find.byType(BooksOfflineNotice), findsNothing);
    });

    testWidgets('a server list offline shows the paused-paging hint', (
      tester,
    ) async {
      stubState(
        BooksState.initial().copyWith(
          bookList: () => listOf(1, totalPages: 3),
          source: () => BooksListSource.server,
          isOffline: true,
          preferences: infinite,
        ),
      );

      await tester.pumpApp(createWidgetUnderTest());

      expect(find.textContaining('Pull to refresh'), findsOneWidget);
    });

    testWidgets('pages mode replaces the pagination with the hint offline', (
      tester,
    ) async {
      stubState(
        BooksState.initial().copyWith(
          bookList: () => listOf(1, totalPages: 3),
          source: () => BooksListSource.server,
          isOffline: true,
          preferences: pages,
        ),
      );

      await tester.pumpApp(createWidgetUnderTest());

      expect(find.byType(Pagination), findsNothing);
      expect(find.textContaining('Pull to refresh'), findsOneWidget);
    });

    testWidgets('the paused hint offers the refresh to screen readers', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      stubState(
        BooksState.initial().copyWith(
          bookList: () => listOf(1, totalPages: 3),
          source: () => BooksListSource.server,
          isOffline: true,
          preferences: pages,
        ),
      );

      await tester.pumpApp(createWidgetUnderTest());
      final hint = find.textContaining('Pull to refresh');
      expect(
        tester.getSemantics(hint),
        matchesSemantics(
          label: 'Pull to refresh to see the books saved on this device.',
          isLiveRegion: true,
          isButton: true,
          hasTapAction: true,
          onTapHint: 'show the books saved on this device',
        ),
      );
      tester.semantics.tap(
        find.semantics.byLabel(
          'Pull to refresh to see the books saved on this device.',
        ),
      );
      verify(() => mockViewModel.refresh()).called(1);
      semantics.dispose();
    });

    testWidgets('the end of an infinite cache list says so', (tester) async {
      stubState(
        BooksState.initial().copyWith(
          bookList: () => listOf(1),
          source: () => BooksListSource.cache,
          isOffline: true,
          preferences: infinite,
        ),
      );

      await tester.pumpApp(createWidgetUnderTest());

      expect(
        find.text('End of the books saved on this device'),
        findsOneWidget,
      );
    });

    testWidgets('a cache list with no match shows the offline copy', (
      tester,
    ) async {
      stubState(
        BooksState.initial().copyWith(
          bookList: () => listOf(0),
          source: () => BooksListSource.cache,
          isOffline: true,
        ),
      );

      await tester.pumpApp(createWidgetUnderTest());

      expect(
        find.text(
          'No saved books match. Try clearing filters or reconnecting.',
        ),
        findsOneWidget,
      );
      expect(find.text('No books found'), findsNothing);
    });

    testWidgets('an offline miss shows the empty view and retry refreshes', (
      tester,
    ) async {
      stubState(
        BooksState.initial().copyWith(isOffline: true, isOfflineMiss: true),
      );

      await tester.pumpApp(createWidgetUnderTest());

      expect(find.byType(AppOfflineEmptyView), findsOneWidget);
      await tester.tap(find.text('Retry'));
      verify(() => mockViewModel.refresh()).called(1);
    });
  });

  group('launch intent', () {
    late ValueNotifier<BooksLaunchIntent?> intent;

    setUp(() {
      intent = ValueNotifier(null);
      when(() => mockViewModel.setSort(any(), any())).thenReturn(null);
    });

    tearDown(() => intent.dispose());

    Widget host() => Provider<BooksViewModel>.value(
      value: mockViewModel,
      child: ValueListenableBuilder<BooksLaunchIntent?>(
        valueListenable: intent,
        builder: (_, value, _) => BooksPage(intent: value),
      ),
    );

    bool searchHasFocus(WidgetTester tester) =>
        tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus;

    void unfocus() => FocusManager.instance.primaryFocus?.unfocus();

    BooksLaunchIntent focus(int nonce) =>
        BooksLaunchIntent(nonce: nonce, focusSearch: true);

    BooksLaunchIntent sort(int nonce, [String by = 'updatedAt']) =>
        BooksLaunchIntent(nonce: nonce, orderBy: by, order: SortOrder.desc);

    testWidgets('a cold open with focus focuses the search field', (
      tester,
    ) async {
      intent.value = focus(1);
      await tester.pumpApp(host());
      await tester.pumpAndSettle();

      expect(searchHasFocus(tester), isTrue);
    });

    testWidgets('a cold open with a sort sorts without focusing', (
      tester,
    ) async {
      intent.value = sort(1);
      await tester.pumpApp(host());
      await tester.pumpAndSettle();

      verify(
        () => mockViewModel.setSort('updatedAt', SortOrder.desc),
      ).called(1);
      expect(searchHasFocus(tester), isFalse);
    });

    testWidgets('an open page applies a focus request that arrives later', (
      tester,
    ) async {
      await tester.pumpApp(host());
      await tester.pumpAndSettle();
      expect(searchHasFocus(tester), isFalse);

      intent.value = focus(1);
      await tester.pumpAndSettle();

      expect(searchHasFocus(tester), isTrue);
    });

    testWidgets('an open page applies a sort request that arrives later', (
      tester,
    ) async {
      await tester.pumpApp(host());
      await tester.pumpAndSettle();
      verifyNever(() => mockViewModel.setSort(any(), any()));

      intent.value = sort(1, 'createdAt');
      await tester.pumpAndSettle();

      verify(
        () => mockViewModel.setSort('createdAt', SortOrder.desc),
      ).called(1);
    });

    testWidgets('the same link tapped again (new nonce) refocuses', (
      tester,
    ) async {
      intent.value = focus(1);
      await tester.pumpApp(host());
      await tester.pumpAndSettle();
      unfocus();
      await tester.pump();
      expect(searchHasFocus(tester), isFalse);

      intent.value = focus(2);
      await tester.pumpAndSettle();

      expect(searchHasFocus(tester), isTrue);
    });

    testWidgets('the same sort link tapped again sorts again', (tester) async {
      intent.value = sort(1);
      await tester.pumpApp(host());
      await tester.pumpAndSettle();

      intent.value = sort(2);
      await tester.pumpAndSettle();

      verify(
        () => mockViewModel.setSort('updatedAt', SortOrder.desc),
      ).called(2);
    });

    testWidgets('a rebuild with the same nonce does not apply it again', (
      tester,
    ) async {
      intent.value = BooksLaunchIntent(
        nonce: 1,
        focusSearch: true,
        orderBy: 'updatedAt',
        order: SortOrder.desc,
      );
      await tester.pumpApp(host());
      await tester.pumpAndSettle();
      unfocus();
      await tester.pump();

      intent.value = BooksLaunchIntent(
        nonce: 1,
        focusSearch: true,
        orderBy: 'updatedAt',
        order: SortOrder.desc,
      );
      await tester.pumpAndSettle();

      expect(searchHasFocus(tester), isFalse);
      verify(() => mockViewModel.setSort(any(), any())).called(1);
    });
  });

  group('profile action', () {
    testWidgets('shows the guest icon and opens settings for a guest', (
      tester,
    ) async {
      await tester.pumpApp(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(tester.widget<AppAvatar>(find.byType(AppAvatar)).guest, isTrue);
      await tester.tap(find.byType(AppProfileAction));
      await tester.pumpAndSettle();
      expect(find.text('Settings Page'), findsOneWidget);
    });

    testWidgets('shows the photo and opens settings when signed in', (
      tester,
    ) async {
      final navigation = MockNavigationViewModel();
      await initTestDI(navigationViewModel: navigation);
      when(
        () => navigation.stateStream,
      ).thenAnswer((_) => const Stream.empty());
      when(() => navigation.state).thenReturn(
        NavigationState(
          user: UserModel(
            id: const UserId('1'),
            email: const UserEmail('maria@example.com'),
            roles: const UserRoles(['user']),
            maxWeightSensitiveContent: const SensitiveContentWeight(0),
            profilePictureUrl: 'http://x/a.webp',
          ),
          isAuthenticated: true,
        ),
      );
      await tester.pumpApp(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final avatar = tester.widget<AppAvatar>(find.byType(AppAvatar));
      expect(avatar.guest, isFalse);
      expect(avatar.imageUrl, 'http://x/a.webp');
      await tester.tap(find.byType(AppProfileAction));
      await tester.pumpAndSettle();
      expect(find.text('Settings Page'), findsOneWidget);
    });
  });

  testWidgets(
    'the router passes a repeated link to the open page, so it refocuses',
    (tester) async {
      when(() => mockViewModel.setSort(any(), any())).thenReturn(null);
      final router = GoRouter(
        initialLocation: '/books?focus=search&n=1',
        routes: [
          GoRoute(
            path: '/books',
            builder: (context, state) => Provider<BooksViewModel>.value(
              value: mockViewModel,
              child: BooksPage(intent: BooksLaunchIntent.fromUri(state.uri)),
            ),
          ),
        ],
      );
      await tester.pumpWidget(
        Provider<NavigationViewModel>.value(
          value: sl<NavigationViewModel>(),
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
      await tester.pumpAndSettle();
      bool focused() =>
          tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus;
      expect(focused(), isTrue);

      for (var i = 0; i < 2; i++) {
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pump();
        expect(focused(), isFalse);
        // Same link, new nonce: the page stays mounted and is told again.
        tester.element(find.byType(BooksPage)).goToBooks(focusSearch: true);
        await tester.pumpAndSettle();
        expect(focused(), isTrue);
        await tester.pump(const Duration(milliseconds: 2));
      }
    },
  );
}
