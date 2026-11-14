import 'dart:async';
import '../../../../core/base/base_stream_view_model.dart';
import '../../../../core/connectivity/connectivity_service.dart';
import '../../../../core/logging/logger.dart';
import '../../../../core/network/exceptions.dart';
import '../../../authentication/domain/use_cases/auth_service.dart';
import '../../../users/data/models/user_model.dart';
import '../../../users/domain/use_cases/user_service.dart';
import '../../../books/domain/repositories/books_repository.dart';
import '../../../books/domain/entities/book_page_options.dart';
import '../../../books/domain/entities/book.dart';
import '../../../books/domain/value_objects/book_id.dart';
import '../../../reading/domain/use_cases/reading_progress_coordinator.dart';
import '../../../../shared/domain/value_objects/positive_int.dart';
import 'package:equatable/equatable.dart';

/// One book list on the home screen and how its last load went.
class HomeBookSection extends Equatable {
  final List<Book> books;
  final bool isLoading;

  /// The last load threw `OfflineException`: nothing is saved for this list.
  final bool unavailableOffline;

  const HomeBookSection({
    this.books = const [],
    this.isLoading = false,
    this.unavailableOffline = false,
  });

  /// Before the first load: skeletons.
  const HomeBookSection.loading() : this(isLoading: true);

  /// Settled with nothing to show because nothing is saved offline.
  bool get isMissingOffline =>
      unavailableOffline && books.isEmpty && !isLoading;

  HomeBookSection copyWith({
    List<Book>? books,
    bool? isLoading,
    bool? unavailableOffline,
  }) {
    return HomeBookSection(
      books: books ?? this.books,
      isLoading: isLoading ?? this.isLoading,
      unavailableOffline: unavailableOffline ?? this.unavailableOffline,
    );
  }

  @override
  List<Object?> get props => [books, isLoading, unavailableOffline];
}

class HomeState extends Equatable {
  final bool isAuthenticated;
  final bool isInitialized;
  final UserModel user;

  /// Latest updates; its first books also feed the featured carousel.
  final HomeBookSection latestUpdated;
  final HomeBookSection recentlyAdded;

  final List<Book> continueReadingBooks;
  final bool isLoadingContinueReading;

  /// The server cannot be reached; the screen shows saved data only.
  final bool isOffline;

  /// The offline retry is probing the server and reloading.
  final bool isRetrying;

  static const int featuredCount = 5;

  const HomeState({
    required this.isAuthenticated,
    required this.isInitialized,
    required this.user,
    required this.latestUpdated,
    required this.recentlyAdded,
    required this.continueReadingBooks,
    required this.isLoadingContinueReading,
    required this.isOffline,
    required this.isRetrying,
  });

  factory HomeState.initial() {
    return HomeState(
      isAuthenticated: false,
      isInitialized: false,
      user: UserModel.guest,
      latestUpdated: const HomeBookSection.loading(),
      recentlyAdded: const HomeBookSection.loading(),
      continueReadingBooks: const [],
      isLoadingContinueReading: false,
      isOffline: false,
      isRetrying: false,
    );
  }

  List<Book> get featuredBooks =>
      latestUpdated.books.take(featuredCount).toList();

  /// Neither book list has anything saved while offline, so the home has
  /// nothing to show but the offline empty view.
  bool get showOfflineEmpty =>
      latestUpdated.isMissingOffline && recentlyAdded.isMissingOffline;

  HomeState copyWith({
    bool? isAuthenticated,
    bool? isInitialized,
    UserModel? user,
    HomeBookSection? latestUpdated,
    HomeBookSection? recentlyAdded,
    List<Book>? continueReadingBooks,
    bool? isLoadingContinueReading,
    bool? isOffline,
    bool? isRetrying,
  }) {
    return HomeState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isInitialized: isInitialized ?? this.isInitialized,
      user: user ?? this.user,
      latestUpdated: latestUpdated ?? this.latestUpdated,
      recentlyAdded: recentlyAdded ?? this.recentlyAdded,
      continueReadingBooks: continueReadingBooks ?? this.continueReadingBooks,
      isLoadingContinueReading:
          isLoadingContinueReading ?? this.isLoadingContinueReading,
      isOffline: isOffline ?? this.isOffline,
      isRetrying: isRetrying ?? this.isRetrying,
    );
  }

  @override
  List<Object?> get props => [
    isAuthenticated,
    isInitialized,
    user,
    latestUpdated,
    recentlyAdded,
    continueReadingBooks,
    isLoadingContinueReading,
    isOffline,
    isRetrying,
  ];
}

class HomeViewModel extends BaseStreamViewModel<HomeState> {
  final AuthService _authService;
  final UserService _userService;
  final BooksRepository _booksRepository;
  final ReadingProgressCoordinator _readingCoordinator;
  final ConnectivityService _connectivity;
  late final StreamSubscription<AuthState> _authSubscription;
  late final StreamSubscription<UserModel> _profileSubscription;
  late final StreamSubscription<ConnectivityStatus> _statusSubscription;
  late final StreamSubscription<void> _reconnectSubscription;

  // Three guards keep the home from fetching the same thing twice:
  // - [_reloading]: a reload requested while one runs (a reconnect during
  //   the first load) joins it.
  // - [_reloadedSinceOnline]: the retry reloads as soon as its probe
  //   succeeds, and `onReconnected` fires a debounce later, usually after
  //   that reload finished; the flag drops that event.
  // - `state.isRetrying`: a second tap on retry while one runs is ignored.
  Future<void>? _reloading;
  bool _reloadedSinceOnline = false;

  static const String _logTag = 'HomeViewModel';

  static const _latestUpdatedOptions = BookPageOptions(
    limit: PositiveInt(12),
    orderBy: 'updatedAt',
    order: SortOrder.desc,
  );

  static const _recentlyAddedOptions = BookPageOptions(
    limit: PositiveInt(12),
    orderBy: 'createdAt',
    order: SortOrder.desc,
  );

  HomeViewModel(
    this._authService,
    this._userService,
    this._booksRepository,
    this._readingCoordinator,
    this._connectivity,
  ) : super(HomeState.initial().copyWith(isOffline: _connectivity.isOffline)) {
    _authSubscription = _authService.authStateStream.listen(
      (_) => _onAuthChanged(),
    );
    _profileSubscription = _userService.profileStream.listen(
      (user) => emit(state.copyWith(user: user)),
    );
    _statusSubscription = _connectivity.statusStream.listen(_onStatus);
    _reconnectSubscription = _connectivity.onReconnected.listen((_) {
      if (!_reloadedSinceOnline) reload();
    });
    _syncAuth();
    reload();
  }

  /// Reloads every section, keeping what is on screen until fresh data
  /// arrives. Joins the reload already in flight, if any.
  Future<void> reload() {
    final inFlight = _reloading;
    if (inFlight != null) return inFlight;
    if (!_connectivity.isOffline) _reloadedSinceOnline = true;
    return _reloading = Future.wait([
      _loadSection(
        _latestUpdatedOptions,
        read: (s) => s.latestUpdated,
        write: (s, section) => s.copyWith(latestUpdated: section),
      ),
      _loadSection(
        _recentlyAddedOptions,
        read: (s) => s.recentlyAdded,
        write: (s, section) => s.copyWith(recentlyAdded: section),
      ),
      _loadContinueReading(),
    ]).whenComplete(() => _reloading = null);
  }

  /// Retry from the offline empty view. Offline, repositories skip the
  /// network, so probe the server first and reload only once it answers.
  Future<void> retry() async {
    if (state.isRetrying) return;
    emit(state.copyWith(isRetrying: true));
    try {
      await _connectivity.checkNow();
      if (!_connectivity.isOffline) await reload();
    } catch (e, stackTrace) {
      AppLogger.e('Error retrying the home screen', e, stackTrace, _logTag);
    } finally {
      emit(state.copyWith(isRetrying: false));
    }
  }

  void _onStatus(ConnectivityStatus status) {
    final offline = status == ConnectivityStatus.offline;
    if (offline) _reloadedSinceOnline = false;
    emit(state.copyWith(isOffline: offline));
  }

  void _syncAuth() {
    emit(
      state.copyWith(
        isAuthenticated: _authService.authenticated,
        isInitialized: _authService.isInitialized,
      ),
    );
  }

  void _onAuthChanged() {
    _syncAuth();
    _loadContinueReading();
  }

  /// Loads one book list. Skeletons only where nothing is shown yet, so a
  /// refresh is silent; a failed refresh keeps the old books.
  Future<void> _loadSection(
    BookPageOptions options, {
    required HomeBookSection Function(HomeState) read,
    required HomeState Function(HomeState, HomeBookSection) write,
  }) async {
    void update(HomeBookSection Function(HomeBookSection) change) =>
        emit(write(state, change(read(state))));

    // Clearing the offline miss up front takes the offline empty view down
    // while a reload (on reconnect) runs.
    update(
      (s) => s.copyWith(isLoading: s.books.isEmpty, unavailableOffline: false),
    );
    try {
      final res = await _booksRepository.getBooks(options);
      update((s) => s.copyWith(books: res.data));
    } on OfflineException {
      update((s) => s.copyWith(unavailableOffline: true));
    } catch (e, stackTrace) {
      AppLogger.e(
        'Error loading books (${options.orderBy})',
        e,
        stackTrace,
        _logTag,
      );
    } finally {
      update((s) => s.copyWith(isLoading: false));
    }
  }

  Future<void> _loadContinueReading() async {
    if (!state.isAuthenticated) {
      emit(state.copyWith(continueReadingBooks: []));
      return;
    }

    emit(
      state.copyWith(
        isLoadingContinueReading: state.continueReadingBooks.isEmpty,
      ),
    );

    try {
      final bookIds = await _readingCoordinator.getContinueReadingBooks(
        limit: 10,
      );
      // Each book on its own: one that is not saved offline (or fails) is
      // left out instead of hiding the whole section.
      final books = await Future.wait(bookIds.map(_bookOrNull));
      emit(
        state.copyWith(continueReadingBooks: books.whereType<Book>().toList()),
      );
    } catch (e, stackTrace) {
      AppLogger.e(
        'Error loading continue reading books',
        e,
        stackTrace,
        _logTag,
      );
    } finally {
      emit(state.copyWith(isLoadingContinueReading: false));
    }
  }

  Future<Book?> _bookOrNull(BookId id) async {
    try {
      return await _booksRepository.getBook(id);
    } on OfflineException {
      return null;
    } catch (e, stackTrace) {
      AppLogger.e(
        'Error loading continue reading book',
        e,
        stackTrace,
        _logTag,
      );
      return null;
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _profileSubscription.cancel();
    _statusSubscription.cancel();
    _reconnectSubscription.cancel();
    super.dispose();
  }
}
