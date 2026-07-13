import '../../../../core/base/base_stream_view_model.dart';
import '../../../../core/logging/logger.dart';
import '../../../../shared/domain/value_objects/positive_int.dart';
import '../../../reading/data/database/reading_database.dart';
import '../../../reading/domain/use_cases/reading_progress_coordinator.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/entities/chapter_page_options.dart';
import '../../domain/repositories/books_repository.dart';
import '../../domain/value_objects/book_id.dart';
import 'package:equatable/equatable.dart';

class BookDetailsState extends Equatable {
  final Book? book;
  final ChapterList? chapterList;
  final ReadingProgressData? lastReadChapter;
  final bool isLoading;
  final bool isLoadingChapters;
  final String? error;
  final String? chaptersError;
  final ChapterPageOptions options;

  const BookDetailsState({
    this.book,
    this.chapterList,
    this.lastReadChapter,
    required this.isLoading,
    required this.isLoadingChapters,
    this.error,
    this.chaptersError,
    required this.options,
  });

  factory BookDetailsState.initial() {
    return const BookDetailsState(
      book: null,
      chapterList: null,
      lastReadChapter: null,
      isLoading: false,
      isLoadingChapters: false,
      error: null,
      chaptersError: null,
      options: ChapterPageOptions(),
    );
  }

  BookDetailsState copyWith({
    Book? Function()? book,
    ChapterList? Function()? chapterList,
    ReadingProgressData? Function()? lastReadChapter,
    bool? isLoading,
    bool? isLoadingChapters,
    String? Function()? error,
    String? Function()? chaptersError,
    ChapterPageOptions? options,
  }) {
    return BookDetailsState(
      book: book != null ? book() : this.book,
      chapterList: chapterList != null ? chapterList() : this.chapterList,
      lastReadChapter: lastReadChapter != null ? lastReadChapter() : this.lastReadChapter,
      isLoading: isLoading ?? this.isLoading,
      isLoadingChapters: isLoadingChapters ?? this.isLoadingChapters,
      error: error != null ? error() : this.error,
      chaptersError: chaptersError != null ? chaptersError() : this.chaptersError,
      options: options ?? this.options,
    );
  }

  @override
  List<Object?> get props => [
        book,
        chapterList,
        lastReadChapter,
        isLoading,
        isLoadingChapters,
        error,
        chaptersError,
        options,
      ];
}

class BookDetailsViewModel extends BaseStreamViewModel<BookDetailsState> {
  final BooksRepository _repository;
  final ReadingProgressCoordinator _progressCoordinator;
  final String bookId;
  static const String _logTag = 'BookDetailsViewModel';

  BookDetailsViewModel({
    required BooksRepository repository,
    required ReadingProgressCoordinator progressCoordinator,
    required this.bookId,
  }) : _repository = repository,
       _progressCoordinator = progressCoordinator,
       super(BookDetailsState.initial());

  Book? get book => state.book;
  ChapterList? get chapterList => state.chapterList;
  ReadingProgressData? get lastReadChapter => state.lastReadChapter;
  bool get isLoading => state.isLoading;
  bool get isLoadingChapters => state.isLoadingChapters;
  String? get error => state.error;
  String? get chaptersError => state.chaptersError;
  ChapterPageOptions get options => state.options;
  bool get hasReadingProgress => state.lastReadChapter != null;

  Future<void> fetchBookDetails() async {
    if (state.isLoading) return;

    AppLogger.i('Fetching book details for ID: $bookId', _logTag);
    emit(state.copyWith(isLoading: true, error: () => null, chaptersError: () => null));

    try {
      final results = await Future.wait([
        _repository.getBook(BookId(bookId)),
        _repository.getBookChapters(BookId(bookId), state.options),
        _progressCoordinator.getLastReadChapter(BookId(bookId)),
        _progressCoordinator.getAllProgressForBook(BookId(bookId)),
      ]);

      final fetchedBook = results[0] as Book;
      final chaptersResult = results[1] as ChapterList;
      final fetchedLastReadChapter = results[2] as ReadingProgressData?;
      final localProgress = results[3] as List<ReadingProgressData>;

      final progressMap = {
        for (var p in localProgress) p.chapterId: p,
      };

      final updatedChapters = chaptersResult.data.map((chapter) {
        final progress = progressMap[chapter.id.value];
        final isCompleted = progress?.completed ?? false;
        return chapter.copyWith(
          completed: isCompleted,
          read: chapter.read || isCompleted || progress != null,
          lastPage: PositiveInt(progress?.pageIndex ?? 0),
        );
      }).toList();

      final newChapterList = chaptersResult.copyWith(data: updatedChapters);

      AppLogger.i(
        'Chapters fetched successfully: id=$bookId, count=${newChapterList.data.length}',
        _logTag,
      );
      AppLogger.d(
        'Fetched last read chapter: ${fetchedLastReadChapter?.chapterId}, completed: ${fetchedLastReadChapter?.completed}',
        _logTag,
      );

      emit(state.copyWith(
        isLoading: false,
        book: () => fetchedBook,
        chapterList: () => newChapterList,
        lastReadChapter: () => fetchedLastReadChapter,
      ));
    } catch (e, stackTrace) {
      AppLogger.e('Error fetching book details', e, stackTrace, _logTag);
      emit(state.copyWith(isLoading: false, error: () => e.toString()));
    }
  }

  Future<void> _fetchLastReadChapter() async {
    try {
      final newLastReadChapter = await _progressCoordinator.getLastReadChapter(BookId(bookId));
      AppLogger.d(
        'Fetched last read chapter: ${newLastReadChapter?.chapterId}, completed: ${newLastReadChapter?.completed}',
        _logTag,
      );
      emit(state.copyWith(lastReadChapter: () => newLastReadChapter));
    } catch (e) {
      AppLogger.w('Error fetching last read chapter: $e', _logTag);
    }
  }

  Future<void> refreshReadStatus() async {
    AppLogger.i('Refreshing read status for book ID: $bookId', _logTag);
    await _fetchLastReadChapter();

    if (state.chapterList != null) {
      final localProgress = await _progressCoordinator.getAllProgressForBook(
        BookId(bookId),
      );

      final progressMap = {
        for (var p in localProgress) p.chapterId: p,
      };

      var changed = false;
      final updatedChapters = state.chapterList!.data.map((chapter) {
        final progress = progressMap[chapter.id.value];

        final isCompleted = progress?.completed ?? false;
        final lastPage = progress?.pageIndex ?? 0;
        // Mark as read if it is completed or if there is any progress (even if not completed)
        final isRead = chapter.read || isCompleted || progress != null;

        if (chapter.completed != isCompleted ||
            chapter.read != isRead ||
            chapter.lastPage.value != lastPage) {
          changed = true;
          return chapter.copyWith(
            completed: isCompleted,
            read: isRead,
            lastPage: PositiveInt(lastPage),
          );
        }
        return chapter;
      }).toList();

      if (changed) {
        AppLogger.d('Marking chapters as read/completed locally', _logTag);
        emit(state.copyWith(chapterList: () => state.chapterList!.copyWith(data: updatedChapters)));
      }
    }
  }

  Future<void> fetchChapters() async {
    if (state.isLoadingChapters) return;

    AppLogger.i('Fetching chapters for ID: $bookId', _logTag);
    emit(state.copyWith(isLoadingChapters: true, chaptersError: () => null));

    try {
      final chaptersResult = await _repository.getBookChapters(
        BookId(bookId),
        state.options,
      );
      final localProgress = await _progressCoordinator.getAllProgressForBook(
        BookId(bookId),
      );

      final progressMap = {
        for (var p in localProgress) p.chapterId: p,
      };

      final updatedChapters = chaptersResult.data.map((chapter) {
        final progress = progressMap[chapter.id.value];
        final isCompleted = progress?.completed ?? false;
        return chapter.copyWith(
          completed: isCompleted,
          read: chapter.read || isCompleted || progress != null,
          lastPage: PositiveInt(progress?.pageIndex ?? 0),
        );
      }).toList();

      final newChapterList = chaptersResult.copyWith(data: updatedChapters);

      AppLogger.i(
        'Chapters fetched successfully: id=$bookId, count=${newChapterList.data.length}',
        _logTag,
      );

      emit(state.copyWith(isLoadingChapters: false, chapterList: () => newChapterList));
    } catch (e, stackTrace) {
      AppLogger.e('Error fetching chapters', e, stackTrace, _logTag);
      emit(state.copyWith(isLoadingChapters: false, chaptersError: () => e.toString()));
    }
  }

  Future<void> loadMoreChapters() async {
    if (state.isLoading ||
        state.isLoadingChapters ||
        state.chapterList == null ||
        !state.chapterList!.hasNextPage) {
      return;
    }

    AppLogger.i('Loading more chapters for ID: $bookId', _logTag);
    emit(state.copyWith(isLoadingChapters: true));

    try {
      final newOptions = state.options.copyWith(cursor: state.chapterList!.nextCursor);
      emit(state.copyWith(options: newOptions));
      final result = await _repository.getBookChapters(BookId(bookId), newOptions);
      final localProgress = await _progressCoordinator.getAllProgressForBook(
        BookId(bookId),
      );

      final progressMap = {
        for (var p in localProgress) p.chapterId: p,
      };

      final updatedNewChapters = result.data.map((chapter) {
        final progress = progressMap[chapter.id.value];
        final isCompleted = progress?.completed ?? false;
        return chapter.copyWith(
          completed: isCompleted,
          read: chapter.read || isCompleted || progress != null,
          lastPage: PositiveInt(progress?.pageIndex ?? 0),
        );
      }).toList();

      final newChapterList = ChapterList(
        data: [...state.chapterList!.data, ...updatedNewChapters],
        nextCursor: result.nextCursor,
        hasNextPage: result.hasNextPage,
      );

      AppLogger.i(
        'More chapters fetched successfully: count=${result.data.length}',
        _logTag,
      );

      emit(state.copyWith(isLoadingChapters: false, chapterList: () => newChapterList));
    } catch (e, stackTrace) {
      AppLogger.e('Error fetching more chapters', e, stackTrace, _logTag);
      emit(state.copyWith(isLoadingChapters: false, chaptersError: () => e.toString()));
    }
  }

  void setChapterOrder(ChapterSortOrder order) {
    if (state.options.order == order) return;
    AppLogger.i('Setting chapter order to: $order', _logTag);
    emit(state.copyWith(options: ChapterPageOptions(order: order), chapterList: () => null));
    fetchChapters();
  }

  void clearError() {
    AppLogger.d('Clearing book details error', _logTag);
    emit(state.copyWith(error: () => null));
  }

  String? getResumeChapterId() {
    final chapters = state.chapterList?.data;
    if (chapters == null || chapters.isEmpty) {
      AppLogger.d('getResumeChapterId: No chapters available', _logTag);
      return null;
    }

    if (state.lastReadChapter == null) {
      final firstId = chapters.first.id.value;
      AppLogger.d(
        'getResumeChapterId: No progress, returning first chapter: $firstId',
        _logTag,
      );
      return firstId;
    }

    final lastChapterId = state.lastReadChapter!.chapterId;
    if (state.lastReadChapter!.completed) {
      // Find next chapter
      final currentIndex = chapters.indexWhere((c) => c.id.value == lastChapterId);
      if (currentIndex != -1 && currentIndex < chapters.length - 1) {
        final nextId = chapters[currentIndex + 1].id.value;
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
    if (state.lastReadChapter == null || state.lastReadChapter!.completed) {
      return 0;
    }
    return state.lastReadChapter!.pageIndex;
  }
}
