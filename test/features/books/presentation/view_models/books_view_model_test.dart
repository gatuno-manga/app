import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/shared/domain/value_objects/positive_int.dart';

import 'package:gatuno/features/books/domain/entities/book.dart';
import 'package:gatuno/features/books/domain/entities/book_page_options.dart';
import 'package:gatuno/features/books/domain/repositories/books_repository.dart';
import 'package:gatuno/features/books/presentation/view_models/books_view_model.dart';
import 'package:gatuno/features/settings/domain/use_cases/settings_service.dart';
import 'package:mocktail/mocktail.dart';

class MockBooksRepository extends Mock implements BooksRepository {}

class MockSettingsService extends Mock implements SettingsService {}

void main() {
  late BooksViewModel viewModel;
  late MockBooksRepository mockRepository;
  late MockSettingsService mockSettingsService;

  setUpAll(() {
    registerFallbackValue(const BookPageOptions());
  });

  setUp(() {
    mockRepository = MockBooksRepository();
    mockSettingsService = MockSettingsService();
    viewModel = BooksViewModel(
      repository: mockRepository,
      settingsService: mockSettingsService,
    );
  });

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
      viewModel = BooksViewModel(
        repository: mockRepository,
        settingsService: mockSettingsService,
      );
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
  });
}
