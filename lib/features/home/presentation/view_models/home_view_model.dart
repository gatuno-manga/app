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

class HomeState extends Equatable {
  final bool isAuthenticated;
  final bool isInitialized;
  final UserModel user;

  final List<Book> featuredBooks;
  final List<Book> continueReadingBooks;
  final List<Book> latestUpdatedBooks;
  final List<Book> recentlyAddedBooks;

  final bool isLoadingFeatured;
  final bool isLoadingGrid;
  final bool isLoadingRecentlyAdded;
  final bool isLoadingContinueReading;

  /// The server cannot be reached; the screen shows saved data only.
  final bool isOffline;

  /// The last load of a list threw `OfflineException`: nothing saved for it.
  final bool latestUnavailableOffline;
  final bool recentUnavailableOffline;

  /// The offline retry is probing the server and reloading.
  final bool isRetrying;

  const HomeState({
    required this.isAuthenticated,
    required this.isInitialized,
    required this.user,
    required this.featuredBooks,
    required this.continueReadingBooks,
    required this.latestUpdatedBooks,
    required this.recentlyAddedBooks,
    required this.isLoadingFeatured,
    required this.isLoadingGrid,
    required this.isLoadingRecentlyAdded,
    required this.isLoadingContinueReading,
    required this.isOffline,
    required this.latestUnavailableOffline,
    required this.recentUnavailableOffline,
    required this.isRetrying,
  });

  /// Neither book list has anything saved while offline, so the home has
  /// nothing to show but the offline empty view.
  bool get showOfflineEmpty =>
      latestUnavailableOffline &&
      recentUnavailableOffline &&
      latestUpdatedBooks.isEmpty &&
      recentlyAddedBooks.isEmpty;

  factory HomeState.initial() {
    return HomeState(
      isAuthenticated: false,
      isInitialized: false,
      user: UserModel.guest,
      featuredBooks: [],
      continueReadingBooks: [],
      latestUpdatedBooks: [],
      recentlyAddedBooks: [],
      isLoadingFeatured: true,
      isLoadingGrid: true,
      isLoadingRecentlyAdded: true,
      isLoadingContinueReading: false,
      isOffline: false,
      latestUnavailableOffline: false,
      recentUnavailableOffline: false,
      isRetrying: false,
    );
  }

  HomeState copyWith({
    bool? isAuthenticated,
    bool? isInitialized,
    UserModel? user,
    List<Book>? featuredBooks,
    List<Book>? continueReadingBooks,
    List<Book>? latestUpdatedBooks,
    List<Book>? recentlyAddedBooks,
    bool? isLoadingFeatured,
    bool? isLoadingGrid,
    bool? isLoadingRecentlyAdded,
    bool? isLoadingContinueReading,
    bool? isOffline,
    bool? latestUnavailableOffline,
    bool? recentUnavailableOffline,
    bool? isRetrying,
  }) {
    return HomeState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isInitialized: isInitialized ?? this.isInitialized,
      user: user ?? this.user,
      featuredBooks: featuredBooks ?? this.featuredBooks,
      continueReadingBooks: continueReadingBooks ?? this.continueReadingBooks,
      latestUpdatedBooks: latestUpdatedBooks ?? this.latestUpdatedBooks,
      recentlyAddedBooks: recentlyAddedBooks ?? this.recentlyAddedBooks,
      isLoadingFeatured: isLoadingFeatured ?? this.isLoadingFeatured,
      isLoadingGrid: isLoadingGrid ?? this.isLoadingGrid,
      isLoadingRecentlyAdded:
          isLoadingRecentlyAdded ?? this.isLoadingRecentlyAdded,
      isLoadingContinueReading:
          isLoadingContinueReading ?? this.isLoadingContinueReading,
      isOffline: isOffline ?? this.isOffline,
      latestUnavailableOffline:
          latestUnavailableOffline ?? this.latestUnavailableOffline,
      recentUnavailableOffline:
          recentUnavailableOffline ?? this.recentUnavailableOffline,
      isRetrying: isRetrying ?? this.isRetrying,
    );
  }

  @override
  List<Object?> get props => [
    isAuthenticated,
    isInitialized,
    user,
    featuredBooks,
    continueReadingBooks,
    latestUpdatedBooks,
    recentlyAddedBooks,
    isLoadingFeatured,
    isLoadingGrid,
    isLoadingRecentlyAdded,
    isLoadingContinueReading,
    isOffline,
    latestUnavailableOffline,
    recentUnavailableOffline,
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

  /// The reload in flight, so a second request (retry, then the reconnect it
  /// causes) joins it instead of fetching twice.
  Future<void>? _reloading;

  /// A reload started while online since the last time the app went offline.
  /// The retry reloads right after its probe succeeds, and `onReconnected`
  /// fires a debounce later; this flag keeps that second event from fetching
  /// everything again.
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
    if (!_connectivity.isOffline) _reloadedSinceOnline = true;
    return _reloading ??= Future.wait([
      _loadLatestUpdated(),
      _loadRecentlyAdded(),
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

  Future<void> _loadLatestUpdated() async {
    // Skeletons only where nothing is shown yet: a refresh is silent.
    final showSkeleton = state.latestUpdatedBooks.isEmpty;
    emit(
      state.copyWith(
        isLoadingFeatured: showSkeleton,
        isLoadingGrid: showSkeleton,
      ),
    );

    try {
      final res = await _booksRepository.getBooks(_latestUpdatedOptions);
      emit(
        state.copyWith(
          featuredBooks: res.data.take(5).toList(),
          latestUpdatedBooks: res.data,
          latestUnavailableOffline: false,
        ),
      );
    } on OfflineException {
      emit(state.copyWith(latestUnavailableOffline: true));
    } catch (e, stackTrace) {
      AppLogger.e('Error loading latest books data', e, stackTrace, _logTag);
    } finally {
      emit(state.copyWith(isLoadingFeatured: false, isLoadingGrid: false));
    }
  }

  Future<void> _loadRecentlyAdded() async {
    emit(
      state.copyWith(isLoadingRecentlyAdded: state.recentlyAddedBooks.isEmpty),
    );

    try {
      final res = await _booksRepository.getBooks(_recentlyAddedOptions);
      emit(
        state.copyWith(
          recentlyAddedBooks: res.data,
          recentUnavailableOffline: false,
        ),
      );
    } on OfflineException {
      emit(state.copyWith(recentUnavailableOffline: true));
    } catch (e, stackTrace) {
      AppLogger.e('Error loading recently added books', e, stackTrace, _logTag);
    } finally {
      emit(state.copyWith(isLoadingRecentlyAdded: false));
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
