import 'dart:async';

import 'package:optional/optional.dart';
import '../../../../core/base/base_stream_view_model.dart';
import '../../../../core/connectivity/connectivity_service.dart';
import '../../../../core/logging/logger.dart';
import '../../../../core/network/exceptions.dart';
import '../../../../shared/domain/value_objects/positive_int.dart';
import '../../../settings/domain/use_cases/settings_service.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/book_page_options.dart';
import '../../domain/entities/book_type.dart';
import '../../domain/entities/books_view_preferences.dart';
import '../../domain/repositories/books_repository.dart';
import '../../domain/repositories/books_view_preferences_repository.dart';
import 'package:equatable/equatable.dart';
import '../models/filter_option.dart';

/// Where the list on screen came from.
enum BooksListSource {
  /// The server answered the request.
  server,

  /// The app was offline, so the offline cache answered: only the books this
  /// device has seen, with local totals.
  cache,
}

class BooksState extends Equatable {
  final BookList? bookList;
  final bool isLoading;

  /// True while a page is being appended after the current books.
  final bool isLoadingMore;
  final String? error;
  final BooksViewPreferences preferences;
  final BookPageOptions options;

  /// Where [bookList] came from; `null` while there is no list.
  final BooksListSource? source;

  /// Whether the server is unreachable right now.
  final bool isOffline;

  /// The last fetch found nothing saved on the device while offline.
  final bool isOfflineMiss;

  /// True while a user-initiated refresh probes the server and reloads.
  final bool isRefreshing;

  const BooksState({
    this.bookList,
    required this.isLoading,
    this.isLoadingMore = false,
    this.error,
    required this.preferences,
    required this.options,
    this.source,
    this.isOffline = false,
    this.isOfflineMiss = false,
    this.isRefreshing = false,
  });

  factory BooksState.initial() {
    return const BooksState(
      bookList: null,
      isLoading: false,
      error: null,
      preferences: BooksViewPreferences(),
      options: BookPageOptions(),
    );
  }

  /// Whether a page after the current one exists.
  bool get hasMore =>
      bookList != null && options.page.value < bookList!.totalPages.value;

  /// Whether the list shows the offline cache rather than the server.
  bool get isCacheList => source == BooksListSource.cache;

  /// A server list while offline: its pages don't line up with the cache's,
  /// so paging waits until the user refreshes (or the server is back).
  bool get isPagingPaused => isOffline && source == BooksListSource.server;

  BooksState copyWith({
    BookList? Function()? bookList,
    bool? isLoading,
    bool? isLoadingMore,
    String? Function()? error,
    BooksViewPreferences? preferences,
    BookPageOptions? options,
    BooksListSource? Function()? source,
    bool? isOffline,
    bool? isOfflineMiss,
    bool? isRefreshing,
  }) {
    return BooksState(
      bookList: bookList != null ? bookList() : this.bookList,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error != null ? error() : this.error,
      preferences: preferences ?? this.preferences,
      options: options ?? this.options,
      source: source != null ? source() : this.source,
      isOffline: isOffline ?? this.isOffline,
      isOfflineMiss: isOfflineMiss ?? this.isOfflineMiss,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
    bookList,
    isLoading,
    isLoadingMore,
    error,
    preferences,
    options,
    source,
    isOffline,
    isOfflineMiss,
    isRefreshing,
  ];
}

class BooksViewModel extends BaseStreamViewModel<BooksState> {
  final BooksRepository _repository;
  final SettingsService _settingsService;
  final BooksViewPreferencesRepository _viewPreferencesRepository;
  final ConnectivityService _connectivity;
  late final StreamSubscription<ConnectivityStatus> _statusSubscription;
  late final StreamSubscription<void> _reconnectSubscription;

  /// The last status seen on the stream. Fetches also write
  /// `state.isOffline`, so transitions are detected against this instead.
  late ConnectivityStatus _lastStatus;
  static const String _logTag = 'BooksViewModel';

  BooksViewModel({
    required BooksRepository repository,
    required SettingsService settingsService,
    required BooksViewPreferencesRepository viewPreferencesRepository,
    required ConnectivityService connectivity,
  }) : _repository = repository,
       _settingsService = settingsService,
       _viewPreferencesRepository = viewPreferencesRepository,
       _connectivity = connectivity,
       super(
         BooksState.initial().copyWith(
           preferences: viewPreferencesRepository.current,
           isOffline: connectivity.isOffline,
         ),
       ) {
    _lastStatus = connectivity.status;
    _statusSubscription = connectivity.statusStream.listen(_onStatus);
    _reconnectSubscription = connectivity.onReconnected.listen(
      (_) => _onReconnected(),
    );
  }

  @override
  void dispose() {
    _statusSubscription.cancel();
    _reconnectSubscription.cancel();
    super.dispose();
  }

  /// Going offline never reloads the list: the user decides when to switch
  /// to the saved books (see [refresh]).
  void _onStatus(ConnectivityStatus status) {
    if (status == _lastStatus) return;
    _lastStatus = status;
    final offline = status == ConnectivityStatus.offline;
    if (offline) _resetPickerOptions();
    emit(state.copyWith(isOffline: offline));
  }

  /// Reloads what offline left behind (the saved books or the empty view);
  /// a server list that stayed on screen is still valid and is kept.
  void _onReconnected() {
    _resetPickerOptions();
    emit(state.copyWith(isOffline: false));
    if (state.isOfflineMiss || state.isCacheList) {
      AppLogger.i('Reconnected: reloading books from page 1', _logTag);
      emit(
        state.copyWith(
          options: state.options.copyWith(page: const PositiveInt(1)),
        ),
      );
      fetchBooks();
    }
  }

  /// User-initiated reload (pull to refresh, the offline retry). Offline, the
  /// repository skips the network, so the server is probed first; then the
  /// list restarts from page 1, from whichever source answers.
  Future<void> refresh() async {
    if (state.isRefreshing) return;
    if (!_connectivity.isOffline) return fetchBooks();

    emit(state.copyWith(isRefreshing: true));
    try {
      await _connectivity.checkNow();
    } catch (e, stackTrace) {
      AppLogger.e('Connectivity probe failed', e, stackTrace, _logTag);
    }
    emit(
      state.copyWith(
        isOffline: _connectivity.isOffline,
        options: state.options.copyWith(page: const PositiveInt(1)),
      ),
    );
    try {
      await fetchBooks();
    } finally {
      emit(state.copyWith(isRefreshing: false));
    }
  }

  BookList? get bookList => state.bookList;
  bool get isLoading => state.isLoading;
  String? get error => state.error;
  bool get isLoadingMore => state.isLoadingMore;
  BooksViewPreferences get preferences => state.preferences;
  bool get hasMore => state.hasMore;
  BookPageOptions get options => state.options;
  bool get isOffline => state.isOffline;
  bool get isCacheList => state.isCacheList;
  bool get isPagingPaused => state.isPagingPaused;
  bool get isOfflineMiss => state.isOfflineMiss;
  bool get isRefreshing => state.isRefreshing;

  bool get _infinite =>
      state.preferences.navigation == BooksNavigationMode.infinite;

  bool _fetchQueued = false;

  /// Fetches the list. A call made while a fetch is in flight is not dropped:
  /// one follow-up fetch runs afterwards with the options then in state, and
  /// the in-flight result is discarded because state no longer describes it.
  /// In infinite navigation the list holds pages 1..N, so a plain fetch
  /// restarts from page 1; with [append] the result is added after the
  /// current books and, on failure, the page is rolled back so the next
  /// attempt retries it.
  Future<void> fetchBooks({bool append = false}) {
    if (state.isLoading) {
      _fetchQueued = true;
      return Future.value();
    }
    return _fetch(append: append);
  }

  Future<void> _fetch({required bool append}) async {
    AppLogger.i(
      'Fetching books: append=$append, page=${state.options.page}',
      _logTag,
    );

    var newOptions = state.options;
    if (!append && _infinite) {
      newOptions = newOptions.copyWith(page: const PositiveInt(1));
    }
    final requestedPage = newOptions.page;

    emit(
      state.copyWith(
        isLoading: true,
        isLoadingMore: append,
        error: () => null,
        options: newOptions,
      ),
    );

    try {
      final sensitiveEnabled = _settingsService.sensitiveContentEnabled;
      List<String>? sensitiveFilter = newOptions.sensitiveContent;

      if (!sensitiveEnabled) {
        sensitiveFilter = ['Safe'];
      }

      final currentOptions = newOptions.copyWith(
        sensitiveContent: Optional.ofNullable(sensitiveFilter),
      );

      final result = await _repository.getBooks(currentOptions);
      if (_takeQueued()) return await _fetch(append: false);
      // A failed request flips the status before the cache answers, so the
      // status now tells which source produced [result].
      final offline = _connectivity.isOffline;
      final source = offline ? BooksListSource.cache : BooksListSource.server;

      AppLogger.i(
        'Books fetched successfully: page=${result.page}, count=${result.data.length}, total=${result.total}',
        _logTag,
      );

      // A page past the first, in either mode, sits at an offset of the
      // list on screen; on the other source that offset means nothing.
      if (state.source != null &&
          source != state.source &&
          requestedPage.value > 1) {
        return await _onSourceChanged(source);
      }

      final previous = state.bookList;
      final merged = append && previous != null
          ? BookList(
              data: [...previous.data, ...result.data],
              total: result.total,
              page: result.page,
              limit: result.limit,
              totalPages: result.totalPages,
            )
          : result;
      emit(
        state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          bookList: () => merged,
          source: () => source,
          isOffline: offline,
          isOfflineMiss: false,
        ),
      );
    } on OfflineException catch (e) {
      AppLogger.w('No saved books for this request: $e', _logTag);
      if (_takeQueued()) return await _fetch(append: false);
      if (append && state.source == BooksListSource.server) {
        // Going offline never takes away the server list being read.
        emit(
          state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            isOffline: true,
            options: _undoPageBump(requestedPage),
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          bookList: () => null,
          source: () => null,
          isOffline: true,
          isOfflineMiss: true,
          options: state.options.copyWith(page: const PositiveInt(1)),
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error fetching books', e, stackTrace, _logTag);
      if (_takeQueued()) return await _fetch(append: false);

      final rolledBack = append ? _undoPageBump(requestedPage) : state.options;
      emit(
        state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: () => e.toString(),
          isOfflineMiss: false,
          options: rolledBack,
        ),
      );
    }
  }

  /// The requested page came from the other source than the list on screen,
  /// so it is discarded. A server list that went offline mid-request stays,
  /// on the page it shows, with paging paused until the user refreshes.
  /// Back online under a cache list, the server list replaces it from
  /// page 1.
  Future<void> _onSourceChanged(BooksListSource source) {
    AppLogger.i(
      'Discarding a page from the ${source.name}: the list on screen came '
      'from the ${state.source?.name}',
      _logTag,
    );
    if (source == BooksListSource.cache) {
      emit(
        state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          isOffline: true,
          options: state.options.copyWith(
            page: state.bookList?.page ?? const PositiveInt(1),
          ),
        ),
      );
      return Future.value();
    }
    emit(
      state.copyWith(
        options: state.options.copyWith(page: const PositiveInt(1)),
      ),
    );
    return _fetch(append: false);
  }

  /// The options with the page bump of an append to [requestedPage] undone,
  /// so the next attempt retries it. Only that bump: a sort or filter change
  /// made meanwhile already moved the page elsewhere.
  BookPageOptions _undoPageBump(PositiveInt requestedPage) =>
      state.options.page == requestedPage
      ? state.options.copyWith(page: PositiveInt(requestedPage.value - 1))
      : state.options;

  /// Whether a follow-up fetch was requested meanwhile; clears the flag.
  bool _takeQueued() {
    if (!_fetchQueued) return false;
    _fetchQueued = false;
    return true;
  }

  /// Pages mode only: infinite mode appends through [loadMore].
  void setPage(int page) {
    if (_infinite ||
        state.isPagingPaused ||
        page < 1 ||
        (state.bookList != null && page > state.bookList!.totalPages.value)) {
      return;
    }
    AppLogger.i('Setting page to: $page', _logTag);
    emit(
      state.copyWith(options: state.options.copyWith(page: PositiveInt(page))),
    );
    fetchBooks();
  }

  /// Appends the next page in infinite mode; a no-op otherwise, while a fetch
  /// is in flight, or when the last page is already loaded.
  Future<void> loadMore() async {
    if (!_infinite ||
        state.isLoading ||
        state.isPagingPaused ||
        !state.hasMore) {
      return;
    }
    final next = state.options.page.value + 1;
    AppLogger.i('Loading more books: page=$next', _logTag);
    emit(
      state.copyWith(options: state.options.copyWith(page: PositiveInt(next))),
    );
    await fetchBooks(append: true);
  }

  void _updatePreferences(BooksViewPreferences preferences) {
    emit(state.copyWith(preferences: preferences));
    _save(preferences);
  }

  void _save(BooksViewPreferences preferences) {
    _viewPreferencesRepository.save(preferences).catchError((
      Object e,
      StackTrace stackTrace,
    ) {
      AppLogger.e('Error saving view preferences', e, stackTrace, _logTag);
    });
  }

  void setLayoutMode(BooksLayoutMode mode) {
    AppLogger.i('Setting layout mode to: $mode', _logTag);
    _updatePreferences(state.preferences.copyWith(layout: mode));
  }

  void setColumns(int columns) {
    final clamped = columns.clamp(
      BooksViewPreferences.minColumns,
      BooksViewPreferences.maxColumns,
    );
    AppLogger.i('Setting columns to: $clamped', _logTag);
    _updatePreferences(state.preferences.copyWith(columns: clamped));
  }

  /// Switching mode drops the loaded list and starts again from page 1.
  void setNavigationMode(BooksNavigationMode mode) {
    if (mode == state.preferences.navigation) return;
    AppLogger.i('Setting navigation mode to: $mode', _logTag);
    final preferences = state.preferences.copyWith(navigation: mode);
    emit(
      state.copyWith(
        preferences: preferences,
        bookList: () => null,
        source: () => null,
        options: state.options.copyWith(page: const PositiveInt(1)),
      ),
    );
    _save(preferences);
    fetchBooks();
  }

  void setSearch(String? search) {
    if (search == null || search.isEmpty) {
      clearSearch();
      return;
    }
    AppLogger.i('Setting search to: $search', _logTag);
    emit(
      state.copyWith(
        options: state.options.copyWith(
          search: Optional.ofNullable(search),
          page: const PositiveInt(1),
        ),
      ),
    );
    fetchBooks();
  }

  void clearSearch() {
    AppLogger.i('Clearing search', _logTag);
    emit(
      state.copyWith(
        options: state.options.copyWith(
          search: const Optional.empty(),
          page: const PositiveInt(1),
        ),
      ),
    );
    fetchBooks();
  }

  void setSort(String orderBy, SortOrder order) {
    AppLogger.i('Setting sort: $orderBy $order', _logTag);
    emit(
      state.copyWith(
        options: state.options.copyWith(
          orderBy: orderBy,
          order: order,
          page: const PositiveInt(1),
        ),
      ),
    );
    fetchBooks();
  }

  void updateFilters({
    int? publication,
    String? publicationOperator,
    List<TypeBook>? type,
    List<String>? tags,
    String? tagsLogic,
    List<String>? excludeTags,
    String? excludeTagsLogic,
    List<String>? authors,
    String? authorsLogic,
    List<String>? sensitiveContent,
  }) {
    AppLogger.i('Updating filters', _logTag);
    emit(
      state.copyWith(
        options: state.options.copyWith(
          publication: Optional.ofNullable(
            publication != null ? PositiveInt(publication) : null,
          ),
          publicationOperator: Optional.ofNullable(publicationOperator),
          type: Optional.ofNullable(type),
          tags: Optional.ofNullable(tags),
          tagsLogic: Optional.ofNullable(tagsLogic),
          excludeTags: Optional.ofNullable(excludeTags),
          excludeTagsLogic: Optional.ofNullable(excludeTagsLogic),
          authors: Optional.ofNullable(authors),
          authorsLogic: Optional.ofNullable(authorsLogic),
          sensitiveContent: Optional.ofNullable(sensitiveContent),
          page: const PositiveInt(1),
        ),
      ),
    );
    fetchBooks();
  }

  void clearFilters() {
    AppLogger.i('Clearing filters', _logTag);
    emit(state.copyWith(options: state.options.withoutFilters()));
    fetchBooks();
  }

  Future<List<FilterOption>>? _tagOptions;
  Future<List<FilterOption>>? _authorOptions;

  /// Tags for the filter picker; cached, and re-requested after a failure.
  Future<List<FilterOption>> loadTagOptions() => _tagOptions ??= _cached(
    () async => [
      for (final t in await _repository.getTags())
        FilterOption(id: t.id.value, label: t.name.value),
    ],
    () => _tagOptions = null,
  );

  /// Authors for the filter picker; cached, and re-requested after a failure.
  Future<List<FilterOption>> loadAuthorOptions() => _authorOptions ??= _cached(
    () async => [
      for (final a in await _repository.getAuthors())
        FilterOption(id: a.id.value, label: a.name.value),
    ],
    () => _authorOptions = null,
  );

  /// Options loaded on one side of a connectivity change come from the other
  /// source (server or cache), so they are requested again.
  void _resetPickerOptions() {
    _tagOptions = null;
    _authorOptions = null;
  }

  Future<List<FilterOption>> _cached(
    Future<List<FilterOption>> Function() load,
    void Function() reset,
  ) async {
    try {
      return await load();
    } catch (_) {
      reset();
      rethrow;
    }
  }

  void clearError() {
    AppLogger.d('Clearing books error', _logTag);
    emit(state.copyWith(error: () => null));
  }
}
