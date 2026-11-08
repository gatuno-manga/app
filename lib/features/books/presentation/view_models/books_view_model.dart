import 'package:optional/optional.dart';
import '../../../../core/base/base_stream_view_model.dart';
import '../../../../core/logging/logger.dart';
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

class BooksState extends Equatable {
  final BookList? bookList;
  final bool isLoading;
  final String? error;
  final BooksViewPreferences preferences;
  final BookPageOptions options;

  const BooksState({
    this.bookList,
    required this.isLoading,
    this.error,
    required this.preferences,
    required this.options,
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

  BooksLayoutMode get layoutMode => preferences.layout;

  /// Whether a page after the current one exists.
  bool get hasMore =>
      bookList != null && options.page.value < bookList!.totalPages.value;

  BooksState copyWith({
    BookList? Function()? bookList,
    bool? isLoading,
    String? Function()? error,
    BooksViewPreferences? preferences,
    BookPageOptions? options,
  }) {
    return BooksState(
      bookList: bookList != null ? bookList() : this.bookList,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      preferences: preferences ?? this.preferences,
      options: options ?? this.options,
    );
  }

  @override
  List<Object?> get props => [bookList, isLoading, error, preferences, options];
}

class BooksViewModel extends BaseStreamViewModel<BooksState> {
  final BooksRepository _repository;
  final SettingsService _settingsService;
  final BooksViewPreferencesRepository _viewPreferencesRepository;
  static const String _logTag = 'BooksViewModel';

  BooksViewModel({
    required BooksRepository repository,
    required SettingsService settingsService,
    required BooksViewPreferencesRepository viewPreferencesRepository,
  }) : _repository = repository,
       _settingsService = settingsService,
       _viewPreferencesRepository = viewPreferencesRepository,
       super(BooksState.initial()) {
    _loadPreferences();
  }

  BookList? get bookList => state.bookList;
  bool get isLoading => state.isLoading;
  String? get error => state.error;
  BooksViewPreferences get preferences => state.preferences;
  BooksLayoutMode get layoutMode => state.layoutMode;
  bool get hasMore => state.hasMore;
  BookPageOptions get options => state.options;

  bool _refetchQueued = false;

  /// Fetches the list. A call made while a fetch is in flight is not dropped:
  /// one follow-up fetch runs afterwards with the latest options (page and
  /// filters are read from state, so `refresh`/`resetPage`/`append` are not
  /// replayed). With [append] the result is added after the current books
  /// and, on failure, the page is rolled back so the next attempt retries it.
  Future<void> fetchBooks({
    bool refresh = false,
    bool resetPage = true,
    bool append = false,
  }) async {
    if (state.isLoading) {
      _refetchQueued = true;
      return;
    }

    AppLogger.i(
      'Fetching books: refresh=$refresh, resetPage=$resetPage, append=$append, page=${state.options.page}',
      _logTag,
    );

    var newOptions = state.options;
    if (refresh && resetPage) {
      newOptions = newOptions.copyWith(page: const PositiveInt(1));
    }

    emit(
      state.copyWith(isLoading: true, error: () => null, options: newOptions),
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

      AppLogger.i(
        'Books fetched successfully: page=${result.page}, count=${result.data.length}, total=${result.total}',
        _logTag,
      );

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
      emit(state.copyWith(isLoading: false, bookList: () => merged));
    } catch (e, stackTrace) {
      AppLogger.e('Error fetching books', e, stackTrace, _logTag);
      final rolledBack = append
          ? state.options.copyWith(
              page: PositiveInt(state.options.page.value - 1),
            )
          : state.options;
      emit(
        state.copyWith(
          isLoading: false,
          error: () => e.toString(),
          options: rolledBack,
        ),
      );
    }

    if (_refetchQueued) {
      _refetchQueued = false;
      await fetchBooks();
    }
  }

  void setPage(int page) {
    if (page < 1 ||
        (state.bookList != null && page > state.bookList!.totalPages.value)) {
      return;
    }
    AppLogger.i('Setting page to: $page', _logTag);
    emit(
      state.copyWith(options: state.options.copyWith(page: PositiveInt(page))),
    );
    fetchBooks();
  }

  void loadNextPage() => setPage(state.options.page.value + 1);

  void loadPreviousPage() => setPage(state.options.page.value - 1);

  /// Appends the next page in infinite mode; a no-op otherwise, while a fetch
  /// is in flight, or when the last page is already loaded.
  Future<void> loadMore() async {
    if (state.preferences.navigation != BooksNavigationMode.infinite ||
        state.isLoading ||
        !state.hasMore) {
      return;
    }
    final next = state.options.page.value + 1;
    AppLogger.i('Loading more books: page=$next', _logTag);
    emit(
      state.copyWith(options: state.options.copyWith(page: PositiveInt(next))),
    );
    await fetchBooks(refresh: false, resetPage: false, append: true);
  }

  bool _preferencesChanged = false;

  Future<void> _loadPreferences() async {
    try {
      final loaded = await _viewPreferencesRepository.load();
      // A change the user made while loading is newer than what was stored.
      if (_preferencesChanged) return;
      emit(state.copyWith(preferences: loaded));
    } catch (e, stackTrace) {
      AppLogger.e('Error loading view preferences', e, stackTrace, _logTag);
    }
  }

  void _updatePreferences(BooksViewPreferences preferences) {
    _preferencesChanged = true;
    emit(state.copyWith(preferences: preferences));
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
    _updatePreferences(state.preferences.copyWith(navigation: mode));
    emit(
      state.copyWith(
        bookList: () => null,
        options: state.options.copyWith(page: const PositiveInt(1)),
      ),
    );
    fetchBooks(refresh: true);
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
    fetchBooks(refresh: true);
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
    fetchBooks(refresh: true);
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
    fetchBooks(refresh: true);
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
    fetchBooks(refresh: true);
  }

  void clearFilters() {
    AppLogger.i('Clearing filters', _logTag);
    emit(state.copyWith(options: state.options.withoutFilters()));
    fetchBooks(refresh: true);
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
