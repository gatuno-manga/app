import '../../../../core/base/safe_change_notifier.dart';
import '../../../../core/logging/logger.dart';
import '../../../authentication/domain/use_cases/auth_service.dart';
import '../../../users/domain/use_cases/user_service.dart';
import '../../../users/data/models/user_model.dart';
import '../../../books/domain/repositories/books_repository.dart';
import '../../../books/domain/entities/book_page_options.dart';
import '../../../books/domain/entities/book.dart';
import '../../../reading/domain/use_cases/reading_progress_coordinator.dart';
import '../../../../shared/domain/value_objects/positive_int.dart';

class HomeViewModel extends SafeChangeNotifier {
  final AuthService _authService;
  final UserService _userService;
  final BooksRepository _booksRepository;
  final ReadingProgressCoordinator _readingCoordinator;
  
  static const String _logTag = 'HomeViewModel';

  UserModel _user = UserModel.guest;

  List<Book> featuredBooks = [];
  List<Book> continueReadingBooks = [];
  List<Book> latestUpdatedBooks = [];
  List<Book> recentlyAddedBooks = [];

  bool isLoadingFeatured = true;
  bool isLoadingGrid = true;
  bool isLoadingRecentlyAdded = true;
  bool isLoadingContinueReading = false;

  HomeViewModel(
    this._authService, 
    this._userService,
    this._booksRepository,
    this._readingCoordinator,
  ) {
    _authService.addListener(_onAuthChanged);
    _loadUser();
    _loadBooksData();
    _loadRecentlyAdded();
    _loadContinueReading();
  }

  void _onAuthChanged() {
    _loadUser();
    _loadContinueReading();
  }

  Future<void> _loadUser() async {
    if (isDisposed) return;

    _user = await _userService.getCurrentUser();
    notifyListeners();
  }

  Future<void> _loadBooksData() async {
    isLoadingFeatured = true;
    isLoadingGrid = true;
    notifyListeners();

    try {
      final res = await _booksRepository.getBooks(
        const BookPageOptions(
          limit: const PositiveInt(12),
          orderBy: 'updatedAt',
          order: SortOrder.desc,
        ),
      );
      
      if (res.data.isNotEmpty) {
        featuredBooks = res.data.take(5).toList();
        latestUpdatedBooks = res.data;
      }
    } catch (e) {
      AppLogger.e('Error loading latest books data', e, null, _logTag);
    } finally {
      isLoadingFeatured = false;
      isLoadingGrid = false;
      notifyListeners();
    }
  }

  Future<void> _loadRecentlyAdded() async {
    isLoadingRecentlyAdded = true;
    notifyListeners();

    try {
      final res = await _booksRepository.getBooks(
        const BookPageOptions(
          limit: const PositiveInt(12),
          orderBy: 'createdAt',
          order: SortOrder.desc,
        ),
      );
      recentlyAddedBooks = res.data;
    } catch (e) {
      AppLogger.e('Error loading recently added books', e, null, _logTag);
    } finally {
      isLoadingRecentlyAdded = false;
      notifyListeners();
    }
  }

  Future<void> _loadContinueReading() async {
    if (!isAuthenticated) {
      continueReadingBooks = [];
      notifyListeners();
      return;
    }

    isLoadingContinueReading = true;
    notifyListeners();

    try {
      final bookIds = await _readingCoordinator.getContinueReadingBooks(limit: 10);
      if (bookIds.isEmpty) {
        continueReadingBooks = [];
        return;
      }

      final futures = bookIds.map((id) => _booksRepository.getBook(id));
      final books = await Future.wait(futures);
      
      continueReadingBooks = books.toList();
    } catch (e) {
      AppLogger.e('Error loading continue reading books', e, null, _logTag);
    } finally {
      isLoadingContinueReading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthChanged);
    super.dispose();
  }

  bool get isAuthenticated => _authService.authenticated;
  bool get isInitialized => _authService.isInitialized;
  String? get displayName => _user.isGuest ? null : _user.displayName;
}
