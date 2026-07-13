import 'dart:async';
import '../../../../core/base/base_stream_view_model.dart';
import '../../../../core/logging/logger.dart';
import '../../../authentication/domain/use_cases/auth_service.dart';
import '../../../users/domain/use_cases/user_service.dart';
import '../../../books/domain/repositories/books_repository.dart';
import '../../../books/domain/entities/book_page_options.dart';
import '../../../books/domain/entities/book.dart';
import '../../../reading/domain/use_cases/reading_progress_coordinator.dart';
import '../../../../shared/domain/value_objects/positive_int.dart';
import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final bool isAuthenticated;
  final bool isInitialized;
  final String? displayName;
  
  final List<Book> featuredBooks;
  final List<Book> continueReadingBooks;
  final List<Book> latestUpdatedBooks;
  final List<Book> recentlyAddedBooks;

  final bool isLoadingFeatured;
  final bool isLoadingGrid;
  final bool isLoadingRecentlyAdded;
  final bool isLoadingContinueReading;

  const HomeState({
    required this.isAuthenticated,
    required this.isInitialized,
    required this.displayName,
    required this.featuredBooks,
    required this.continueReadingBooks,
    required this.latestUpdatedBooks,
    required this.recentlyAddedBooks,
    required this.isLoadingFeatured,
    required this.isLoadingGrid,
    required this.isLoadingRecentlyAdded,
    required this.isLoadingContinueReading,
  });

  factory HomeState.initial() {
    return const HomeState(
      isAuthenticated: false,
      isInitialized: false,
      displayName: null,
      featuredBooks: [],
      continueReadingBooks: [],
      latestUpdatedBooks: [],
      recentlyAddedBooks: [],
      isLoadingFeatured: true,
      isLoadingGrid: true,
      isLoadingRecentlyAdded: true,
      isLoadingContinueReading: false,
    );
  }

  HomeState copyWith({
    bool? isAuthenticated,
    bool? isInitialized,
    String? Function()? displayName,
    List<Book>? featuredBooks,
    List<Book>? continueReadingBooks,
    List<Book>? latestUpdatedBooks,
    List<Book>? recentlyAddedBooks,
    bool? isLoadingFeatured,
    bool? isLoadingGrid,
    bool? isLoadingRecentlyAdded,
    bool? isLoadingContinueReading,
  }) {
    return HomeState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isInitialized: isInitialized ?? this.isInitialized,
      displayName: displayName != null ? displayName() : this.displayName,
      featuredBooks: featuredBooks ?? this.featuredBooks,
      continueReadingBooks: continueReadingBooks ?? this.continueReadingBooks,
      latestUpdatedBooks: latestUpdatedBooks ?? this.latestUpdatedBooks,
      recentlyAddedBooks: recentlyAddedBooks ?? this.recentlyAddedBooks,
      isLoadingFeatured: isLoadingFeatured ?? this.isLoadingFeatured,
      isLoadingGrid: isLoadingGrid ?? this.isLoadingGrid,
      isLoadingRecentlyAdded: isLoadingRecentlyAdded ?? this.isLoadingRecentlyAdded,
      isLoadingContinueReading: isLoadingContinueReading ?? this.isLoadingContinueReading,
    );
  }

  @override
  List<Object?> get props => [
    isAuthenticated,
    isInitialized,
    displayName,
    featuredBooks,
    continueReadingBooks,
    latestUpdatedBooks,
    recentlyAddedBooks,
    isLoadingFeatured,
    isLoadingGrid,
    isLoadingRecentlyAdded,
    isLoadingContinueReading,
  ];
}

class HomeViewModel extends BaseStreamViewModel<HomeState> {
  final AuthService _authService;
  final UserService _userService;
  final BooksRepository _booksRepository;
  final ReadingProgressCoordinator _readingCoordinator;
  late final StreamSubscription<AuthState> _authSubscription;
  
  static const String _logTag = 'HomeViewModel';

  HomeViewModel(
    this._authService, 
    this._userService,
    this._booksRepository,
    this._readingCoordinator,
  ) : super(HomeState.initial()) {
    _authSubscription = _authService.authStateStream.listen((_) => _onAuthChanged());
    _onAuthChanged(); // Initialize state from auth service
    _loadBooksData();
    _loadRecentlyAdded();
  }

  void _onAuthChanged() {
    emit(state.copyWith(
      isAuthenticated: _authService.authenticated,
      isInitialized: _authService.isInitialized,
    ));
    _loadUser();
    _loadContinueReading();
  }

  Future<void> _loadUser() async {
    final user = await _userService.getCurrentUser();
    emit(state.copyWith(
      displayName: () => user.isGuest ? null : user.displayName,
    ));
  }

  Future<void> _loadBooksData() async {
    emit(state.copyWith(isLoadingFeatured: true, isLoadingGrid: true));

    try {
      final res = await _booksRepository.getBooks(
        const BookPageOptions(
          limit: PositiveInt(12),
          orderBy: 'updatedAt',
          order: SortOrder.desc,
        ),
      );
      
      if (res.data.isNotEmpty) {
        emit(state.copyWith(
          featuredBooks: res.data.take(5).toList(),
          latestUpdatedBooks: res.data,
        ));
      }
    } catch (e) {
      AppLogger.e('Error loading latest books data', e, null, _logTag);
    } finally {
      emit(state.copyWith(isLoadingFeatured: false, isLoadingGrid: false));
    }
  }

  Future<void> _loadRecentlyAdded() async {
    emit(state.copyWith(isLoadingRecentlyAdded: true));

    try {
      final res = await _booksRepository.getBooks(
        const BookPageOptions(
          limit: PositiveInt(12),
          orderBy: 'createdAt',
          order: SortOrder.desc,
        ),
      );
      emit(state.copyWith(recentlyAddedBooks: res.data));
    } catch (e) {
      AppLogger.e('Error loading recently added books', e, null, _logTag);
    } finally {
      emit(state.copyWith(isLoadingRecentlyAdded: false));
    }
  }

  Future<void> _loadContinueReading() async {
    if (!state.isAuthenticated) {
      emit(state.copyWith(continueReadingBooks: []));
      return;
    }

    emit(state.copyWith(isLoadingContinueReading: true));

    try {
      final bookIds = await _readingCoordinator.getContinueReadingBooks(limit: 10);
      if (bookIds.isEmpty) {
        emit(state.copyWith(continueReadingBooks: []));
        return;
      }

      final futures = bookIds.map((id) => _booksRepository.getBook(id));
      final books = await Future.wait(futures);
      
      emit(state.copyWith(continueReadingBooks: books.toList()));
    } catch (e) {
      AppLogger.e('Error loading continue reading books', e, null, _logTag);
    } finally {
      emit(state.copyWith(isLoadingContinueReading: false));
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
