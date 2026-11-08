import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/shared/domain/value_objects/positive_int.dart';

import 'package:gatuno/features/books/domain/entities/book.dart';
import 'package:gatuno/features/books/domain/entities/book_page_options.dart';
import 'package:gatuno/features/books/domain/entities/books_view_preferences.dart';
import 'package:gatuno/features/books/domain/entities/tag.dart';
import 'package:gatuno/features/books/domain/value_objects/tag_id.dart';
import 'package:gatuno/features/books/domain/value_objects/tag_name.dart';
import 'package:gatuno/features/books/domain/repositories/books_repository.dart';
import 'package:gatuno/features/books/domain/repositories/books_view_preferences_repository.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart';
import 'package:gatuno/features/books/presentation/view_models/books_view_model.dart';
import 'package:gatuno/features/settings/domain/use_cases/settings_service.dart';
import 'package:mocktail/mocktail.dart';

class MockBooksRepository extends Mock implements BooksRepository {}

class MockSettingsService extends Mock implements SettingsService {}

class MockViewPreferencesRepository extends Mock
    implements BooksViewPreferencesRepository {}

void main() {
  late BooksViewModel viewModel;
  late MockBooksRepository mockRepository;
  late MockSettingsService mockSettingsService;
  late MockViewPreferencesRepository mockPrefsRepository;

  setUpAll(() {
    registerFallbackValue(const BookPageOptions());
    registerFallbackValue(const BooksViewPreferences());
  });

  setUp(() {
    mockRepository = MockBooksRepository();
    mockSettingsService = MockSettingsService();
    mockPrefsRepository = MockViewPreferencesRepository();
    when(
      () => mockPrefsRepository.load(),
    ).thenAnswer((_) async => const BooksViewPreferences());
    when(() => mockPrefsRepository.save(any())).thenAnswer((_) async {});
    viewModel = BooksViewModel(
      repository: mockRepository,
      settingsService: mockSettingsService,
      viewPreferencesRepository: mockPrefsRepository,
    );
  });

  BookList page({
    required int number,
    required int totalPages,
    List<String> ids = const [],
  }) {
    return BookList(
      data: [for (final id in ids) Book(id: BookId(id), title: BookTitle(id))],
      total: PositiveInt(totalPages * 20),
      page: PositiveInt(number),
      limit: const PositiveInt(20),
      totalPages: PositiveInt(totalPages),
    );
  }

  Future<void> flush() => Future<void>.delayed(Duration.zero);

  group('BooksViewModel', () {
    test('initial state is correct', () {
      expect(viewModel.isLoading, false);
      expect(viewModel.error, null);
      expect(viewModel.bookList, null);
      expect(viewModel.layoutMode, BooksLayoutMode.grid);
    });

    test('fetchBooks success updates state correctly', () async {
      final bookList = BookList(
        data: [],
        total: const PositiveInt(0),
        page: const PositiveInt(1),
        limit: const PositiveInt(20),
        totalPages: const PositiveInt(1),
      );

      when(() => mockSettingsService.sensitiveContentEnabled).thenReturn(false);
      when(
        () => mockRepository.getBooks(any()),
      ).thenAnswer((_) async => bookList);

      await viewModel.fetchBooks();

      expect(viewModel.isLoading, false);
      expect(viewModel.error, null);
      expect(viewModel.bookList, bookList);
    });

    test('fetchBooks failure updates state correctly', () async {
      when(() => mockSettingsService.sensitiveContentEnabled).thenReturn(false);
      when(
        () => mockRepository.getBooks(any()),
      ).thenThrow(Exception('Failed to fetch books'));

      await viewModel.fetchBooks();

      expect(viewModel.isLoading, false);
      expect(viewModel.error, 'Exception: Failed to fetch books');
    });

    test('clearError resets error message', () async {
      when(() => mockSettingsService.sensitiveContentEnabled).thenReturn(false);
      when(() => mockRepository.getBooks(any())).thenThrow(Exception('Error'));

      await viewModel.fetchBooks();
      expect(viewModel.error, isNotNull);

      viewModel.clearError();
      expect(viewModel.error, null);
    });

    test('setSearch(null) should clear search filter', () async {
      final bookList = BookList(
        data: [],
        total: const PositiveInt(0),
        page: const PositiveInt(1),
        limit: const PositiveInt(20),
        totalPages: const PositiveInt(1),
      );

      when(() => mockSettingsService.sensitiveContentEnabled).thenReturn(false);
      when(
        () => mockRepository.getBooks(any()),
      ).thenAnswer((_) async => bookList);

      // Set search initially
      viewModel.setSearch('test');
      expect(viewModel.options.search, 'test');

      // Attempt to clear search
      viewModel.setSearch(null);

      expect(viewModel.options.search, null);
    });

    test(
      'fetchBooks called while loading queues one follow-up fetch',
      () async {
        final bookList = BookList(
          data: [],
          total: const PositiveInt(0),
          page: const PositiveInt(1),
          limit: const PositiveInt(20),
          totalPages: const PositiveInt(1),
        );
        final first = Completer<BookList>();
        final seen = <BookPageOptions>[];
        var calls = 0;

        when(
          () => mockSettingsService.sensitiveContentEnabled,
        ).thenReturn(true);
        when(() => mockRepository.getBooks(any())).thenAnswer((inv) {
          seen.add(inv.positionalArguments.first as BookPageOptions);
          calls++;
          return calls == 1 ? first.future : Future.value(bookList);
        });

        final inFlight = viewModel.fetchBooks(refresh: true);
        viewModel.updateFilters(publication: 2020);
        viewModel.updateFilters(publication: 2021);
        first.complete(bookList);
        await inFlight;
        await Future<void>.delayed(Duration.zero);

        expect(calls, 2);
        expect(seen.last.publication?.value, 2021);
        expect(viewModel.isLoading, false);
      },
    );

    test('clearFilters keeps search, sort and limit', () async {
      final bookList = BookList(
        data: [],
        total: const PositiveInt(0),
        page: const PositiveInt(1),
        limit: const PositiveInt(20),
        totalPages: const PositiveInt(1),
      );
      when(() => mockSettingsService.sensitiveContentEnabled).thenReturn(true);
      when(
        () => mockRepository.getBooks(any()),
      ).thenAnswer((_) async => bookList);

      viewModel.setSearch('naruto');
      await Future<void>.delayed(Duration.zero);
      viewModel.setSort('title', SortOrder.asc);
      await Future<void>.delayed(Duration.zero);
      viewModel.updateFilters(
        publication: 2020,
        publicationOperator: 'gt',
        tags: ['t1'],
        authors: ['a1'],
      );
      await Future<void>.delayed(Duration.zero);

      viewModel.clearFilters();
      await Future<void>.delayed(Duration.zero);

      final o = viewModel.options;
      expect(o.search, 'naruto');
      expect(o.orderBy, 'title');
      expect(o.order, SortOrder.asc);
      expect(o.publication, isNull);
      expect(o.publicationOperator, isNull);
      expect(o.tags, isNull);
      expect(o.authors, isNull);
      expect(o.page.value, 1);
    });

    test('loadTagOptions caches success and retries after failure', () async {
      var calls = 0;
      when(() => mockRepository.getTags()).thenAnswer((_) async {
        calls++;
        if (calls == 1) throw Exception('boom');
        return [const Tag(id: TagId('t1'), name: TagName('Action'))];
      });

      await expectLater(viewModel.loadTagOptions(), throwsException);
      final ok = await viewModel.loadTagOptions();
      await viewModel.loadTagOptions();

      expect(ok.single.label, 'Action');
      expect(calls, 2);
    });
  });

  group('BooksViewModel view preferences', () {
    test('initial preferences are defaults', () {
      expect(viewModel.preferences, const BooksViewPreferences());
      expect(viewModel.layoutMode, BooksLayoutMode.grid);
    });

    test('stored preferences are applied after construction', () async {
      const stored = BooksViewPreferences(
        layout: BooksLayoutMode.list,
        columns: 3,
        navigation: BooksNavigationMode.pages,
      );
      when(() => mockPrefsRepository.load()).thenAnswer((_) async => stored);

      viewModel = BooksViewModel(
        repository: mockRepository,
        settingsService: mockSettingsService,
        viewPreferencesRepository: mockPrefsRepository,
      );
      await flush();

      expect(viewModel.preferences, stored);
    });

    test('a change made before the load finishes wins', () async {
      final load = Completer<BooksViewPreferences>();
      when(() => mockPrefsRepository.load()).thenAnswer((_) => load.future);
      viewModel = BooksViewModel(
        repository: mockRepository,
        settingsService: mockSettingsService,
        viewPreferencesRepository: mockPrefsRepository,
      );

      viewModel.setLayoutMode(BooksLayoutMode.cover);
      load.complete(const BooksViewPreferences(layout: BooksLayoutMode.list));
      await flush();

      expect(viewModel.layoutMode, BooksLayoutMode.cover);
    });

    test('setLayoutMode saves and does not fetch', () async {
      viewModel.setLayoutMode(BooksLayoutMode.list);
      await flush();

      expect(viewModel.layoutMode, BooksLayoutMode.list);
      verify(
        () => mockPrefsRepository.save(
          const BooksViewPreferences(layout: BooksLayoutMode.list),
        ),
      ).called(1);
      verifyNever(() => mockRepository.getBooks(any()));
    });

    test('setColumns clamps to the allowed range and saves', () async {
      viewModel.setColumns(9);
      expect(viewModel.preferences.columns, 4);
      viewModel.setColumns(0);
      expect(viewModel.preferences.columns, 1);
      viewModel.setColumns(3);
      await flush();

      expect(viewModel.preferences.columns, 3);
      verify(() => mockPrefsRepository.save(any())).called(3);
      verifyNever(() => mockRepository.getBooks(any()));
    });

    test('setNavigationMode with the current value is a no-op', () async {
      viewModel.setNavigationMode(BooksNavigationMode.infinite);
      await flush();

      verifyNever(() => mockPrefsRepository.save(any()));
      verifyNever(() => mockRepository.getBooks(any()));
    });

    test('setNavigationMode clears the list and refetches page 1', () async {
      when(() => mockSettingsService.sensitiveContentEnabled).thenReturn(true);
      final seen = <BookPageOptions>[];
      when(() => mockRepository.getBooks(any())).thenAnswer((inv) async {
        seen.add(inv.positionalArguments.first as BookPageOptions);
        return page(number: 1, totalPages: 3, ids: ['a']);
      });
      await viewModel.fetchBooks();
      viewModel.setPage(3);
      await flush();
      final states = <BooksState>[];
      final sub = viewModel.stateStream.listen(states.add);

      viewModel.setNavigationMode(BooksNavigationMode.pages);
      await flush();
      await sub.cancel();

      expect(viewModel.preferences.navigation, BooksNavigationMode.pages);
      expect(states.any((s) => s.bookList == null), isTrue);
      expect(seen.last.page.value, 1);
      expect(viewModel.bookList, isNotNull);
    });
  });

  group('BooksViewModel loadMore', () {
    setUp(() {
      when(() => mockSettingsService.sensitiveContentEnabled).thenReturn(true);
    });

    test('appends the next page in infinite mode', () async {
      when(() => mockRepository.getBooks(any())).thenAnswer((inv) async {
        final options = inv.positionalArguments.first as BookPageOptions;
        return options.page.value == 1
            ? page(number: 1, totalPages: 2, ids: ['a', 'b'])
            : page(number: 2, totalPages: 2, ids: ['c']);
      });
      await viewModel.fetchBooks();
      expect(viewModel.hasMore, isTrue);

      await viewModel.loadMore();

      expect(viewModel.bookList!.data.map((b) => b.id.value), ['a', 'b', 'c']);
      expect(viewModel.options.page.value, 2);
      expect(viewModel.hasMore, isFalse);
    });

    test('is ignored in pages mode', () async {
      when(
        () => mockRepository.getBooks(any()),
      ).thenAnswer((_) async => page(number: 1, totalPages: 2, ids: ['a']));
      viewModel.setNavigationMode(BooksNavigationMode.pages);
      await flush();
      clearInteractions(mockRepository);

      await viewModel.loadMore();

      verifyNever(() => mockRepository.getBooks(any()));
      expect(viewModel.options.page.value, 1);
    });

    test('is ignored when there are no more pages', () async {
      when(
        () => mockRepository.getBooks(any()),
      ).thenAnswer((_) async => page(number: 1, totalPages: 1, ids: ['a']));
      await viewModel.fetchBooks();
      clearInteractions(mockRepository);

      await viewModel.loadMore();

      verifyNever(() => mockRepository.getBooks(any()));
    });

    test('is ignored while a fetch is in flight', () async {
      final second = Completer<BookList>();
      var calls = 0;
      when(() => mockRepository.getBooks(any())).thenAnswer((_) {
        calls++;
        return calls == 1
            ? Future.value(page(number: 1, totalPages: 3, ids: ['a']))
            : second.future;
      });
      await viewModel.fetchBooks();

      final inFlight = viewModel.loadMore();
      await viewModel.loadMore();
      second.complete(page(number: 2, totalPages: 3, ids: ['b']));
      await inFlight;
      await flush();

      expect(calls, 2);
      expect(viewModel.options.page.value, 2);
      expect(viewModel.bookList!.data.map((b) => b.id.value), ['a', 'b']);
    });

    test(
      'failure keeps the books, rolls the page back and sets error',
      () async {
        var calls = 0;
        when(() => mockRepository.getBooks(any())).thenAnswer((_) async {
          calls++;
          if (calls == 1) return page(number: 1, totalPages: 3, ids: ['a']);
          throw Exception('offline');
        });
        await viewModel.fetchBooks();

        await viewModel.loadMore();

        expect(viewModel.bookList!.data.map((b) => b.id.value), ['a']);
        expect(viewModel.options.page.value, 1);
        expect(viewModel.error, 'Exception: offline');
        expect(viewModel.isLoading, isFalse);
      },
    );
  });
}
