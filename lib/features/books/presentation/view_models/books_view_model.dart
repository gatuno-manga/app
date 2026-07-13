import 'package:optional/optional.dart';
import '../../../../core/base/base_stream_view_model.dart';
import '../../../../core/logging/logger.dart';
import '../../../../shared/domain/value_objects/positive_int.dart';
import '../../../settings/domain/use_cases/settings_service.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/book_page_options.dart';
import '../../domain/entities/book_type.dart';
import '../../domain/repositories/books_repository.dart';
import 'package:equatable/equatable.dart';

enum BooksLayoutMode { grid, list }

class BooksState extends Equatable {
  final BookList? bookList;
  final bool isLoading;
  final String? error;
  final BooksLayoutMode layoutMode;
  final BookPageOptions options;

  const BooksState({
    this.bookList,
    required this.isLoading,
    this.error,
    required this.layoutMode,
    required this.options,
  });

  factory BooksState.initial() {
    return const BooksState(
      bookList: null,
      isLoading: false,
      error: null,
      layoutMode: BooksLayoutMode.grid,
      options: BookPageOptions(),
    );
  }

  BooksState copyWith({
    BookList? Function()? bookList,
    bool? isLoading,
    String? Function()? error,
    BooksLayoutMode? layoutMode,
    BookPageOptions? options,
  }) {
    return BooksState(
      bookList: bookList != null ? bookList() : this.bookList,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      layoutMode: layoutMode ?? this.layoutMode,
      options: options ?? this.options,
    );
  }

  @override
  List<Object?> get props => [
        bookList,
        isLoading,
        error,
        layoutMode,
        options,
      ];
}

class BooksViewModel extends BaseStreamViewModel<BooksState> {
  final BooksRepository _repository;
  final SettingsService _settingsService;
  static const String _logTag = 'BooksViewModel';

  BooksViewModel({
    required BooksRepository repository,
    required SettingsService settingsService,
  }) : _repository = repository,
       _settingsService = settingsService,
       super(BooksState.initial());

  BookList? get bookList => state.bookList;
  bool get isLoading => state.isLoading;
  String? get error => state.error;
  BooksLayoutMode get layoutMode => state.layoutMode;
  BookPageOptions get options => state.options;

  Future<void> fetchBooks({bool refresh = false, bool resetPage = true}) async {
    if (state.isLoading) return;

    AppLogger.i(
      'Fetching books: refresh=$refresh, resetPage=$resetPage, page=${state.options.page}',
      _logTag,
    );
    
    var newOptions = state.options;
    if (refresh && resetPage) {
      newOptions = newOptions.copyWith(page: const PositiveInt(1));
    }
    
    emit(state.copyWith(isLoading: true, error: () => null, options: newOptions));

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
      
      emit(state.copyWith(isLoading: false, bookList: () => result));
    } catch (e, stackTrace) {
      AppLogger.e('Error fetching books', e, stackTrace, _logTag);
      emit(state.copyWith(isLoading: false, error: () => e.toString()));
    }
  }

  void setPage(int page) {
    if (page < 1 || (state.bookList != null && page > state.bookList!.totalPages.value)) {
      return;
    }
    AppLogger.i('Setting page to: $page', _logTag);
    emit(state.copyWith(options: state.options.copyWith(page: PositiveInt(page))));
    fetchBooks();
  }

  void loadNextPage() => setPage(state.options.page.value + 1);

  void loadPreviousPage() => setPage(state.options.page.value - 1);

  void setLayoutMode(BooksLayoutMode mode) {
    AppLogger.i('Setting layout mode to: $mode', _logTag);
    emit(state.copyWith(layoutMode: mode));
  }

  void setSearch(String? search) {
    if (search == null || search.isEmpty) {
      clearSearch();
      return;
    }
    AppLogger.i('Setting search to: $search', _logTag);
    emit(state.copyWith(options: state.options.copyWith(search: Optional.ofNullable(search), page: const PositiveInt(1))));
    fetchBooks(refresh: true);
  }

  void clearSearch() {
    AppLogger.i('Clearing search', _logTag);
    emit(state.copyWith(options: state.options.copyWith(search: const Optional.empty(), page: const PositiveInt(1))));
    fetchBooks(refresh: true);
  }

  void setSort(String orderBy, SortOrder order) {
    AppLogger.i('Setting sort: $orderBy $order', _logTag);
    emit(state.copyWith(options: state.options.copyWith(orderBy: orderBy, order: order, page: const PositiveInt(1))));
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
    emit(state.copyWith(options: state.options.copyWith(
      publication: Optional.ofNullable(publication != null ? PositiveInt(publication) : null),
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
    )));
    fetchBooks(refresh: true);
  }

  void clearFilters() {
    AppLogger.i('Clearing filters', _logTag);
    emit(state.copyWith(options: const BookPageOptions()));
    fetchBooks(refresh: true);
  }

  void clearError() {
    AppLogger.d('Clearing books error', _logTag);
    emit(state.copyWith(error: () => null));
  }
}
