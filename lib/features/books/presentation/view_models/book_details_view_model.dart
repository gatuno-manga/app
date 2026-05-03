import '../../../../core/base/safe_change_notifier.dart';
import '../../../../core/logging/logger.dart';
import '../../../reading/data/database/reading_database.dart';
import '../../../reading/domain/use_cases/reading_progress_coordinator.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/entities/chapter_page_options.dart';
import '../../domain/repositories/books_repository.dart';

class BookDetailsViewModel extends SafeChangeNotifier {
  final BooksRepository _repository;
  final ReadingProgressCoordinator _progressCoordinator;
  final String bookId;
  static const String _logTag = 'BookDetailsViewModel';

  BookDetailsViewModel({
    required BooksRepository repository,
    required ReadingProgressCoordinator progressCoordinator,
    required this.bookId,
  }) : _repository = repository,
       _progressCoordinator = progressCoordinator;

  Book? _book;
  Book? get book => _book;

  ChapterList? _chapterList;
  ChapterList? get chapterList => _chapterList;

  ReadingProgressData? _lastReadChapter;
  ReadingProgressData? get lastReadChapter => _lastReadChapter;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingChapters = false;
  bool get isLoadingChapters => _isLoadingChapters;

  String? _error;
  String? get error => _error;

  String? _chaptersError;
  String? get chaptersError => _chaptersError;

  ChapterPageOptions _options = const ChapterPageOptions();
  ChapterPageOptions get options => _options;

  bool get hasReadingProgress => _lastReadChapter != null;

  Future<void> fetchBookDetails() async {
    if (_isLoading) return;

    AppLogger.i('Fetching book details for ID: $bookId', _logTag);
    _isLoading = true;
    _error = null;
    _chaptersError = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getBook(bookId),
        _repository.getBookChapters(bookId, _options),
        _progressCoordinator.getLastReadChapter(bookId),
        _progressCoordinator.getAllProgressForBook(bookId),
      ]);

      _book = results[0] as Book;
      final chaptersResult = results[1] as ChapterList;
      _lastReadChapter = results[2] as ReadingProgressData?;
      final localProgress = results[3] as List<ReadingProgressData>;

      final progressMap = {
        for (var p in localProgress) p.chapterId: p,
      };

      final updatedChapters = chaptersResult.data.map((chapter) {
        final progress = progressMap[chapter.id];
        final isCompleted = progress?.completed ?? false;
        return chapter.copyWith(
          completed: isCompleted,
          read: chapter.read || isCompleted || progress != null,
          lastPage: progress?.pageIndex ?? 0,
        );
      }).toList();

      _chapterList = chaptersResult.copyWith(data: updatedChapters);

      AppLogger.i(
        'Chapters fetched successfully: id=$bookId, count=${_chapterList?.data.length}',
        _logTag,
      );
      AppLogger.d(
        'Fetched last read chapter: ${_lastReadChapter?.chapterId}, completed: ${_lastReadChapter?.completed}',
        _logTag,
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error fetching book details', e, stackTrace, _logTag);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchLastReadChapter() async {
    try {
      _lastReadChapter = await _progressCoordinator.getLastReadChapter(bookId);
      AppLogger.d(
        'Fetched last read chapter: ${_lastReadChapter?.chapterId}, completed: ${_lastReadChapter?.completed}',
        _logTag,
      );
      notifyListeners();
    } catch (e) {
      AppLogger.w('Error fetching last read chapter: $e', _logTag);
    }
  }

  Future<void> refreshReadStatus() async {
    AppLogger.i('Refreshing read status for book ID: $bookId', _logTag);
    await _fetchLastReadChapter();

    if (_chapterList != null) {
      final localProgress = await _progressCoordinator.getAllProgressForBook(
        bookId,
      );

      final progressMap = {
        for (var p in localProgress) p.chapterId: p,
      };

      var changed = false;
      final updatedChapters = _chapterList!.data.map((chapter) {
        final progress = progressMap[chapter.id];

        final isCompleted = progress?.completed ?? false;
        final lastPage = progress?.pageIndex ?? 0;
        // Mark as read if it is completed or if there is any progress (even if not completed)
        final isRead = chapter.read || isCompleted || progress != null;

        if (chapter.completed != isCompleted ||
            chapter.read != isRead ||
            chapter.lastPage != lastPage) {
          changed = true;
          return chapter.copyWith(
            completed: isCompleted,
            read: isRead,
            lastPage: lastPage,
          );
        }
        return chapter;
      }).toList();

      if (changed) {
        AppLogger.d('Marking chapters as read/completed locally', _logTag);
        _chapterList = _chapterList!.copyWith(data: updatedChapters);
        notifyListeners();
      }
    }
  }

  Future<void> fetchChapters() async {
    if (_isLoadingChapters) return;

    AppLogger.i('Fetching chapters for ID: $bookId', _logTag);
    _isLoadingChapters = true;
    _chaptersError = null;
    notifyListeners();

    try {
      final chaptersResult = await _repository.getBookChapters(
        bookId,
        _options,
      );
      final localProgress = await _progressCoordinator.getAllProgressForBook(
        bookId,
      );

      final progressMap = {
        for (var p in localProgress) p.chapterId: p,
      };

      final updatedChapters = chaptersResult.data.map((chapter) {
        final progress = progressMap[chapter.id];
        final isCompleted = progress?.completed ?? false;
        return chapter.copyWith(
          completed: isCompleted,
          read: chapter.read || isCompleted || progress != null,
          lastPage: progress?.pageIndex ?? 0,
        );
      }).toList();

      _chapterList = chaptersResult.copyWith(data: updatedChapters);

      AppLogger.i(
        'Chapters fetched successfully: id=$bookId, count=${_chapterList?.data.length}',
        _logTag,
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error fetching chapters', e, stackTrace, _logTag);
      _chaptersError = e.toString();
    } finally {
      _isLoadingChapters = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreChapters() async {
    if (_isLoading ||
        _isLoadingChapters ||
        _chapterList == null ||
        !_chapterList!.hasNextPage) {
      return;
    }

    AppLogger.i('Loading more chapters for ID: $bookId', _logTag);
    _isLoadingChapters = true;
    notifyListeners();

    try {
      _options = _options.copyWith(cursor: _chapterList!.nextCursor);
      final result = await _repository.getBookChapters(bookId, _options);
      final localProgress = await _progressCoordinator.getAllProgressForBook(
        bookId,
      );

      final progressMap = {
        for (var p in localProgress) p.chapterId: p,
      };

      final updatedNewChapters = result.data.map((chapter) {
        final progress = progressMap[chapter.id];
        final isCompleted = progress?.completed ?? false;
        return chapter.copyWith(
          completed: isCompleted,
          read: chapter.read || isCompleted || progress != null,
          lastPage: progress?.pageIndex ?? 0,
        );
      }).toList();

      _chapterList = ChapterList(
        data: [..._chapterList!.data, ...updatedNewChapters],
        nextCursor: result.nextCursor,
        hasNextPage: result.hasNextPage,
      );

      AppLogger.i(
        'More chapters fetched successfully: count=${result.data.length}',
        _logTag,
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error fetching more chapters', e, stackTrace, _logTag);
      _chaptersError = e.toString();
    } finally {
      _isLoadingChapters = false;
      notifyListeners();
    }
  }

  void setChapterOrder(ChapterSortOrder order) {
    if (_options.order == order) return;
    AppLogger.i('Setting chapter order to: $order', _logTag);
    _options = ChapterPageOptions(order: order);
    _chapterList = null;
    fetchChapters();
  }

  void clearError() {
    AppLogger.d('Clearing book details error', _logTag);
    _error = null;
    notifyListeners();
  }

  String? getResumeChapterId() {
    final chapters = _chapterList?.data;
    if (chapters == null || chapters.isEmpty) {
      AppLogger.d('getResumeChapterId: No chapters available', _logTag);
      return null;
    }

    if (_lastReadChapter == null) {
      final firstId = chapters.first.id;
      AppLogger.d(
        'getResumeChapterId: No progress, returning first chapter: $firstId',
        _logTag,
      );
      return firstId;
    }

    final lastChapterId = _lastReadChapter!.chapterId;
    if (_lastReadChapter!.completed) {
      // Find next chapter
      final currentIndex = chapters.indexWhere((c) => c.id == lastChapterId);
      if (currentIndex != -1 && currentIndex < chapters.length - 1) {
        final nextId = chapters[currentIndex + 1].id;
        AppLogger.d(
          'getResumeChapterId: Last chapter completed, returning next chapter: $nextId',
          _logTag,
        );
        return nextId;
      }
      AppLogger.d(
        'getResumeChapterId: Last chapter completed and it was the last in list, returning current: $lastChapterId',
        _logTag,
      );
    } else {
      AppLogger.d(
        'getResumeChapterId: Returning last read chapter: $lastChapterId',
        _logTag,
      );
    }

    return lastChapterId;
  }

  int getResumePageIndex() {
    if (_lastReadChapter == null || _lastReadChapter!.completed) {
      return 0;
    }
    return _lastReadChapter!.pageIndex;
  }
}
