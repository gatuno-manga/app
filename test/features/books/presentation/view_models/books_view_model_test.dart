import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/connectivity/connectivity_service.dart';
import 'package:gatuno/core/network/exceptions.dart';
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

/// Connectivity the test drives: [goOffline] / [goOnline] change the status,
/// [reconnect] fires `onReconnected`, and [checkNow] applies [probeResult].
class FakeConnectivityService implements ConnectivityService {
  final _statuses = StreamController<ConnectivityStatus>.broadcast();
  final _reconnects = StreamController<void>.broadcast();
  ConnectivityStatus _status = ConnectivityStatus.online;
  ConnectivityStatus probeResult = ConnectivityStatus.offline;
  int checks = 0;

  @override
  ConnectivityStatus get status => _status;

  @override
  Stream<ConnectivityStatus> get statusStream => _statuses.stream;

  @override
  Stream<void> get onReconnected => _reconnects.stream;

  void _set(ConnectivityStatus value) {
    _status = value;
    _statuses.add(value);
  }

  void goOffline() => _set(ConnectivityStatus.offline);

  void goOnline() => _set(ConnectivityStatus.online);

  void reconnect() {
    goOnline();
    _reconnects.add(null);
  }

  @override
  void reportReachable() => _set(ConnectivityStatus.online);

  @override
  void reportUnreachable() => _set(ConnectivityStatus.offline);

  @override
  Future<void> checkNow() async {
    checks++;
    _set(probeResult);
  }

  Future<void> close() async {
    await _statuses.close();
    await _reconnects.close();
  }
}

void main() {
  late BooksViewModel viewModel;
  late MockBooksRepository mockRepository;
  late MockSettingsService mockSettingsService;
  late MockViewPreferencesRepository mockPrefsRepository;
  late FakeConnectivityService connectivity;

  setUpAll(() {
    registerFallbackValue(const BookPageOptions());
    registerFallbackValue(const BooksViewPreferences());
  });

  setUp(() {
    mockRepository = MockBooksRepository();
    mockSettingsService = MockSettingsService();
    mockPrefsRepository = MockViewPreferencesRepository();
    when(
      () => mockPrefsRepository.current,
    ).thenReturn(const BooksViewPreferences());
    when(() => mockPrefsRepository.save(any())).thenAnswer((_) async {});
    connectivity = FakeConnectivityService();
    viewModel = BooksViewModel(
      repository: mockRepository,
      settingsService: mockSettingsService,
      viewPreferencesRepository: mockPrefsRepository,
      connectivity: connectivity,
    );
  });

  tearDown(() async {
    viewModel.dispose();
    await connectivity.close();
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
      expect(viewModel.preferences.layout, BooksLayoutMode.grid);
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

        final inFlight = viewModel.fetchBooks();
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
      expect(viewModel.preferences.layout, BooksLayoutMode.grid);
    });

    test('seeds preferences from the repository on construction', () {
      const stored = BooksViewPreferences(
        layout: BooksLayoutMode.list,
        columns: 3,
        navigation: BooksNavigationMode.pages,
      );
      when(() => mockPrefsRepository.current).thenReturn(stored);

      viewModel.dispose();
      viewModel = BooksViewModel(
        repository: mockRepository,
        settingsService: mockSettingsService,
        viewPreferencesRepository: mockPrefsRepository,
        connectivity: connectivity,
      );

      expect(viewModel.preferences, stored);
    });

    test('setLayoutMode saves and does not fetch', () async {
      viewModel.setLayoutMode(BooksLayoutMode.list);
      await flush();

      expect(viewModel.preferences.layout, BooksLayoutMode.list);
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

    test(
      'switching infinite to pages drops the list and fetches page 1',
      () async {
        when(
          () => mockSettingsService.sensitiveContentEnabled,
        ).thenReturn(true);
        final seen = <int>[];
        when(() => mockRepository.getBooks(any())).thenAnswer((inv) async {
          final o = inv.positionalArguments.first as BookPageOptions;
          seen.add(o.page.value);
          return page(number: o.page.value, totalPages: 3, ids: ['p${o.page}']);
        });
        await viewModel.fetchBooks();
        await viewModel.loadMore();
        expect(viewModel.options.page.value, 2);
        final states = <BooksState>[];
        final sub = viewModel.stateStream.listen(states.add);

        viewModel.setNavigationMode(BooksNavigationMode.pages);
        await flush();
        await sub.cancel();

        expect(viewModel.preferences.navigation, BooksNavigationMode.pages);
        expect(states.any((s) => s.bookList == null), isTrue);
        expect(seen.last, 1);
        expect(viewModel.options.page.value, 1);
        expect(viewModel.bookList!.data.length, 1);
      },
    );

    test(
      'switching pages to infinite drops the page and fetches page 1',
      () async {
        when(
          () => mockSettingsService.sensitiveContentEnabled,
        ).thenReturn(true);
        final seen = <int>[];
        when(() => mockRepository.getBooks(any())).thenAnswer((inv) async {
          final o = inv.positionalArguments.first as BookPageOptions;
          seen.add(o.page.value);
          return page(number: o.page.value, totalPages: 3, ids: ['p${o.page}']);
        });
        viewModel.setNavigationMode(BooksNavigationMode.pages);
        await flush();
        viewModel.setPage(2);
        await flush();
        expect(seen.last, 2);

        viewModel.setNavigationMode(BooksNavigationMode.infinite);
        await flush();

        expect(seen.last, 1);
        expect(viewModel.options.page.value, 1);
      },
    );

    test('setPage is ignored in infinite mode', () async {
      when(() => mockSettingsService.sensitiveContentEnabled).thenReturn(true);
      when(
        () => mockRepository.getBooks(any()),
      ).thenAnswer((_) async => page(number: 1, totalPages: 3, ids: ['a']));
      await viewModel.fetchBooks();
      clearInteractions(mockRepository);

      viewModel.setPage(3);
      await flush();

      expect(viewModel.options.page.value, 1);
      verifyNever(() => mockRepository.getBooks(any()));
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

    test('a result that lands while a fetch is queued is not shown', () async {
      final second = Completer<BookList>();
      when(() => mockRepository.getBooks(any())).thenAnswer((inv) {
        final o = inv.positionalArguments.first as BookPageOptions;
        if (o.page.value == 2) return second.future;
        return Future.value(page(number: 1, totalPages: 3, ids: ['a']));
      });
      await viewModel.fetchBooks();
      final append = viewModel.loadMore();
      final states = <BooksState>[];
      final sub = viewModel.stateStream.listen(states.add);

      viewModel.setNavigationMode(BooksNavigationMode.pages);
      second.complete(page(number: 2, totalPages: 3, ids: ['stale']));
      await append;
      await flush();
      await sub.cancel();

      final shown = states.expand((s) => s.bookList?.data ?? const <Book>[]);
      expect(shown.map((b) => b.id.value), isNot(contains('stale')));
      expect(viewModel.bookList!.data.map((b) => b.id.value), ['a']);
      expect(viewModel.isLoading, isFalse);
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

  group('BooksViewModel fetch queueing and preferences', () {
    setUp(() {
      when(() => mockSettingsService.sensitiveContentEnabled).thenReturn(true);
    });

    test('setNavigationMode emits one state with the reset list', () async {
      when(
        () => mockRepository.getBooks(any()),
      ).thenAnswer((_) async => page(number: 1, totalPages: 2, ids: ['a']));
      await viewModel.fetchBooks();
      final states = <BooksState>[];
      final sub = viewModel.stateStream.skip(1).listen(states.add);

      viewModel.setNavigationMode(BooksNavigationMode.pages);
      await flush();
      await sub.cancel();

      final first = states.first;
      expect(first.preferences.navigation, BooksNavigationMode.pages);
      expect(first.bookList, isNull);
      expect(first.options.page.value, 1);
    });

    test('a plain fetch in infinite mode restarts from page 1', () async {
      final seen = <int>[];
      when(() => mockRepository.getBooks(any())).thenAnswer((inv) async {
        final o = inv.positionalArguments.first as BookPageOptions;
        seen.add(o.page.value);
        return page(number: o.page.value, totalPages: 3, ids: ['p${o.page}']);
      });
      await viewModel.fetchBooks();
      await viewModel.loadMore();

      await viewModel.fetchBooks();

      expect(seen, [1, 2, 1]);
      expect(viewModel.bookList!.data.length, 1);
      expect(viewModel.options.page.value, 1);
    });

    test('a plain fetch in pages mode keeps the current page', () async {
      final seen = <int>[];
      when(() => mockRepository.getBooks(any())).thenAnswer((inv) async {
        final o = inv.positionalArguments.first as BookPageOptions;
        seen.add(o.page.value);
        return page(number: o.page.value, totalPages: 3, ids: ['p${o.page}']);
      });
      viewModel.setNavigationMode(BooksNavigationMode.pages);
      await flush();
      viewModel.setPage(2);
      await flush();

      await viewModel.fetchBooks();

      expect(seen.last, 2);
    });

    test(
      'a fetch queued during an append still restarts from page 1',
      () async {
        final second = Completer<BookList>();
        final seen = <int>[];
        when(() => mockRepository.getBooks(any())).thenAnswer((inv) {
          final o = inv.positionalArguments.first as BookPageOptions;
          seen.add(o.page.value);
          if (o.page.value == 2) return second.future;
          return Future.value(page(number: 1, totalPages: 3, ids: ['a', 'b']));
        });
        await viewModel.fetchBooks();

        final append = viewModel.loadMore();
        final refresh = viewModel.fetchBooks();
        second.complete(page(number: 2, totalPages: 3, ids: ['c']));
        await append;
        await refresh;
        await flush();

        expect(seen, [1, 2, 1]);
        expect(viewModel.options.page.value, 1);
        expect(viewModel.bookList!.data.map((b) => b.id.value), ['a', 'b']);
      },
    );

    test(
      'a failed append after a sort change runs the queued fetch quietly',
      () async {
        final second = Completer<BookList>();
        final seen = <int>[];
        when(() => mockRepository.getBooks(any())).thenAnswer((inv) {
          final o = inv.positionalArguments.first as BookPageOptions;
          seen.add(o.page.value);
          if (o.page.value == 2) return second.future;
          return Future.value(page(number: 1, totalPages: 3, ids: ['a']));
        });
        await viewModel.fetchBooks();
        final states = <BooksState>[];
        final sub = viewModel.stateStream.listen(states.add);

        final append = viewModel.loadMore();
        viewModel.setSort('title', SortOrder.asc);
        second.completeError(Exception('offline'));
        await append;
        await flush();

        expect(seen, [1, 2, 1]);
        expect(viewModel.options.page.value, 1);
        expect(viewModel.error, isNull);
        expect(states.every((s) => s.error == null), isTrue);
        expect(viewModel.isLoading, isFalse);

        // The queued flag must not leak into the next plain fetch.
        await viewModel.fetchBooks();
        await sub.cancel();
        expect(seen, [1, 2, 1, 1]);
      },
    );

    test('isLoadingMore is true only while appending', () async {
      final second = Completer<BookList>();
      when(() => mockRepository.getBooks(any())).thenAnswer((inv) {
        final o = inv.positionalArguments.first as BookPageOptions;
        if (o.page.value == 2) return second.future;
        return Future.value(page(number: 1, totalPages: 3, ids: ['a']));
      });
      final first = viewModel.fetchBooks();
      expect(viewModel.isLoading, isTrue);
      expect(viewModel.isLoadingMore, isFalse);
      await first;

      final append = viewModel.loadMore();
      expect(viewModel.isLoadingMore, isTrue);
      second.complete(page(number: 2, totalPages: 3, ids: ['b']));
      await append;

      expect(viewModel.isLoadingMore, isFalse);
    });
  });

  group('BooksViewModel offline', () {
    setUp(() {
      when(() => mockSettingsService.sensitiveContentEnabled).thenReturn(true);
    });

    /// Answers every page out of [totalPages]; while [connectivity] is
    /// offline the answer stands for the cache, as the read-through
    /// repository does.
    void stubPages({int totalPages = 3}) {
      when(() => mockRepository.getBooks(any())).thenAnswer((inv) async {
        final o = inv.positionalArguments.first as BookPageOptions;
        final prefix = connectivity.isOffline ? 'cache' : 'server';
        return page(
          number: o.page.value,
          totalPages: totalPages,
          ids: ['$prefix-${o.page.value}'],
        );
      });
    }

    List<int> requestedPages() => [
      for (final call in verify(
        () => mockRepository.getBooks(captureAny()),
      ).captured)
        (call as BookPageOptions).page.value,
    ];

    BooksViewModel inPagesMode() {
      when(() => mockPrefsRepository.current).thenReturn(
        const BooksViewPreferences(navigation: BooksNavigationMode.pages),
      );
      viewModel.dispose();
      return viewModel = BooksViewModel(
        repository: mockRepository,
        settingsService: mockSettingsService,
        viewPreferencesRepository: mockPrefsRepository,
        connectivity: connectivity,
      );
    }

    test('marks a list fetched online as coming from the server', () async {
      stubPages();
      await viewModel.fetchBooks();

      expect(viewModel.state.source, BooksListSource.server);
      expect(viewModel.isCacheList, isFalse);
    });

    test('marks a list answered while offline as the cache', () async {
      stubPages();
      connectivity.goOffline();
      await flush();
      await viewModel.fetchBooks();

      expect(viewModel.state.source, BooksListSource.cache);
      expect(viewModel.isCacheList, isTrue);
      expect(viewModel.isOffline, isTrue);
    });

    test('a request that falls back to the cache is a cache list', () async {
      when(() => mockRepository.getBooks(any())).thenAnswer((_) async {
        connectivity.reportUnreachable();
        return page(number: 1, totalPages: 1, ids: ['cache-1']);
      });
      await viewModel.fetchBooks();

      expect(viewModel.state.source, BooksListSource.cache);
    });

    test('going offline keeps the list and does not fetch', () async {
      stubPages();
      await viewModel.fetchBooks();
      clearInteractions(mockRepository);

      connectivity.goOffline();
      await flush();

      verifyNever(() => mockRepository.getBooks(any()));
      expect(viewModel.bookList!.data.single.id.value, 'server-1');
      expect(viewModel.isOffline, isTrue);
      expect(viewModel.isPagingPaused, isTrue);
    });

    test('a server list pauses loadMore while offline', () async {
      stubPages();
      await viewModel.fetchBooks();
      clearInteractions(mockRepository);
      connectivity.goOffline();
      await flush();

      await viewModel.loadMore();

      verifyNever(() => mockRepository.getBooks(any()));
      expect(viewModel.options.page.value, 1);
    });

    test('a server list pauses page changes while offline', () async {
      inPagesMode();
      stubPages();
      await viewModel.fetchBooks();
      clearInteractions(mockRepository);
      connectivity.goOffline();
      await flush();

      viewModel.setPage(2);
      await flush();

      verifyNever(() => mockRepository.getBooks(any()));
      expect(viewModel.options.page.value, 1);
    });

    test('a cache list pages against the cache', () async {
      stubPages();
      connectivity.goOffline();
      await flush();
      await viewModel.fetchBooks();

      await viewModel.loadMore();

      expect(viewModel.bookList!.data.map((b) => b.id.value), [
        'cache-1',
        'cache-2',
      ]);
      expect(viewModel.isPagingPaused, isFalse);
    });

    test(
      'a cache page answering loadMore is not appended to a server list',
      () async {
        stubPages();
        await viewModel.fetchBooks();
        when(() => mockRepository.getBooks(any())).thenAnswer((_) async {
          connectivity.reportUnreachable();
          return page(number: 2, totalPages: 1, ids: ['cache-2']);
        });

        await viewModel.loadMore();

        expect(viewModel.bookList!.data.map((b) => b.id.value), ['server-1']);
        expect(viewModel.state.source, BooksListSource.server);
        expect(viewModel.options.page.value, 1);
        expect(viewModel.isPagingPaused, isTrue);
        expect(viewModel.isLoading, isFalse);
      },
    );

    test(
      'a server page answering loadMore replaces a cache list from page 1',
      () async {
        stubPages();
        connectivity.goOffline();
        await flush();
        await viewModel.fetchBooks();
        // Back online without onReconnected (a false alarm, or before the
        // debounce): the next page comes from the server.
        connectivity.goOnline();
        await flush();
        clearInteractions(mockRepository);

        await viewModel.loadMore();

        expect(requestedPages(), [2, 1]);
        expect(viewModel.bookList!.data.map((b) => b.id.value), ['server-1']);
        expect(viewModel.state.source, BooksListSource.server);
        expect(viewModel.options.page.value, 1);
      },
    );

    test(
      'a page change answered by the cache keeps the server page, paused',
      () async {
        inPagesMode();
        stubPages(totalPages: 5);
        await viewModel.fetchBooks();
        viewModel.setPage(2);
        await flush();
        when(() => mockRepository.getBooks(any())).thenAnswer((inv) async {
          // The request for page 3 drops and the cache answers it.
          connectivity.reportUnreachable();
          final o = inv.positionalArguments.first as BookPageOptions;
          return page(number: o.page.value, totalPages: 1, ids: ['cache-x']);
        });
        clearInteractions(mockRepository);

        viewModel.setPage(3);
        await flush();
        await flush();

        expect(requestedPages(), [3]);
        expect(viewModel.options.page.value, 2);
        expect(viewModel.bookList!.data.single.id.value, 'server-2');
        expect(viewModel.state.source, BooksListSource.server);
        expect(viewModel.isPagingPaused, isTrue);
        expect(viewModel.isLoading, isFalse);
      },
    );

    test(
      'an offline miss while appending to a cache list shows the miss',
      () async {
        stubPages();
        connectivity.goOffline();
        await flush();
        await viewModel.fetchBooks();
        when(
          () => mockRepository.getBooks(any()),
        ).thenThrow(OfflineException());

        await viewModel.loadMore();

        expect(viewModel.isOfflineMiss, isTrue);
        expect(viewModel.bookList, isNull);
      },
    );

    test('a refresh while one is running is ignored', () async {
      stubPages();
      connectivity.goOffline();
      await flush();
      await viewModel.fetchBooks();

      final first = viewModel.refresh();
      await viewModel.refresh();
      await first;

      expect(connectivity.checks, 1);
    });

    test('an offline miss while appending keeps a server list', () async {
      stubPages();
      await viewModel.fetchBooks();
      when(() => mockRepository.getBooks(any())).thenAnswer((_) async {
        connectivity.reportUnreachable();
        throw OfflineException();
      });

      await viewModel.loadMore();

      expect(viewModel.bookList!.data.single.id.value, 'server-1');
      expect(viewModel.isOfflineMiss, isFalse);
      expect(viewModel.options.page.value, 1);
      expect(viewModel.isPagingPaused, isTrue);
    });

    test(
      'switching navigation mode forgets the source with the list',
      () async {
        stubPages();
        connectivity.goOffline();
        await flush();
        await viewModel.fetchBooks();
        final states = <BooksState>[];
        final sub = viewModel.stateStream.listen(states.add);

        viewModel.setNavigationMode(BooksNavigationMode.pages);
        await flush();
        await sub.cancel();

        expect(
          states.any((s) => s.bookList == null && s.source == null),
          isTrue,
        );
      },
    );

    test('the picker reset runs even when a fetch saw offline first', () async {
      when(() => mockRepository.getTags()).thenAnswer(
        (_) async => [const Tag(id: TagId('t'), name: TagName('T'))],
      );
      await viewModel.loadTagOptions();
      when(() => mockRepository.getBooks(any())).thenAnswer((_) async {
        connectivity.reportUnreachable();
        return page(number: 1, totalPages: 1, ids: ['cache-1']);
      });
      // The fetch writes isOffline before the status event is delivered.
      await viewModel.fetchBooks();
      await flush();

      await viewModel.loadTagOptions();
      verify(() => mockRepository.getTags()).called(2);
    });

    test('an offline refresh probes the server, then loads page 1', () async {
      inPagesMode();
      stubPages();
      await viewModel.fetchBooks();
      viewModel.setPage(2);
      await flush();
      connectivity.goOffline();
      await flush();
      clearInteractions(mockRepository);

      final refreshing = viewModel.refresh();
      expect(viewModel.isRefreshing, isTrue);
      await refreshing;

      expect(connectivity.checks, 1);
      expect(requestedPages(), [1]);
      expect(viewModel.isRefreshing, isFalse);
      expect(viewModel.state.source, BooksListSource.cache);
      expect(viewModel.bookList!.data.single.id.value, 'cache-1');
    });

    test(
      'an offline refresh gets server data when the probe succeeds',
      () async {
        stubPages();
        connectivity.goOffline();
        await flush();
        await viewModel.fetchBooks();
        connectivity.probeResult = ConnectivityStatus.online;

        await viewModel.refresh();

        expect(viewModel.state.source, BooksListSource.server);
        expect(viewModel.isOffline, isFalse);
        expect(viewModel.bookList!.data.single.id.value, 'server-1');
      },
    );

    test('an online refresh does not probe', () async {
      stubPages();
      await viewModel.refresh();

      expect(connectivity.checks, 0);
      expect(viewModel.state.source, BooksListSource.server);
    });

    test('OfflineException shows the offline miss, not an error', () async {
      when(() => mockRepository.getBooks(any())).thenThrow(OfflineException());
      connectivity.goOffline();
      await flush();

      await viewModel.fetchBooks();

      expect(viewModel.isOfflineMiss, isTrue);
      expect(viewModel.error, isNull);
      expect(viewModel.bookList, isNull);
    });

    test('reconnecting reloads page 1 after an offline miss', () async {
      when(() => mockRepository.getBooks(any())).thenThrow(OfflineException());
      connectivity.goOffline();
      await flush();
      await viewModel.fetchBooks();
      stubPages();
      clearInteractions(mockRepository);

      connectivity.reconnect();
      await flush();
      await flush();

      expect(requestedPages(), [1]);
      expect(viewModel.isOfflineMiss, isFalse);
      expect(viewModel.state.source, BooksListSource.server);
    });

    test('reconnecting reloads a cache list from page 1', () async {
      stubPages();
      connectivity.goOffline();
      await flush();
      await viewModel.fetchBooks();
      await viewModel.loadMore();
      clearInteractions(mockRepository);

      connectivity.reconnect();
      await flush();
      await flush();

      expect(requestedPages(), [1]);
      expect(viewModel.bookList!.data.single.id.value, 'server-1');
    });

    test('reconnecting keeps a server list', () async {
      stubPages();
      await viewModel.fetchBooks();
      await viewModel.loadMore();
      connectivity.goOffline();
      await flush();
      clearInteractions(mockRepository);

      connectivity.reconnect();
      await flush();

      verifyNever(() => mockRepository.getBooks(any()));
      expect(viewModel.bookList!.data, hasLength(2));
      expect(viewModel.isPagingPaused, isFalse);
    });

    test('picker options are requested again after going offline and '
        'after reconnecting', () async {
      when(() => mockRepository.getTags()).thenAnswer(
        (_) async => [const Tag(id: TagId('t'), name: TagName('T'))],
      );
      await viewModel.loadTagOptions();
      await viewModel.loadTagOptions();
      verify(() => mockRepository.getTags()).called(1);

      connectivity.goOffline();
      await flush();
      await viewModel.loadTagOptions();
      verify(() => mockRepository.getTags()).called(1);

      connectivity.reconnect();
      await flush();
      await viewModel.loadTagOptions();
      verify(() => mockRepository.getTags()).called(1);
    });

    test('dispose cancels the connectivity subscriptions', () async {
      stubPages();
      connectivity.goOffline();
      await flush();
      await viewModel.fetchBooks();
      clearInteractions(mockRepository);
      viewModel.dispose();

      connectivity.reconnect();
      await flush();

      verifyNever(() => mockRepository.getBooks(any()));
    });
  });
}
