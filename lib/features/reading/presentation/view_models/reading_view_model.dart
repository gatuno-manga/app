import '../../../../core/base/base_stream_view_model.dart';
import '../../../../core/logging/logger.dart';
import '../../domain/entities/reading_chapter.dart';
import '../../domain/entities/reading_enums.dart';
import '../../domain/repositories/reading_repository.dart';
import '../../domain/use_cases/reading_progress_coordinator.dart';
import '../../../../features/books/domain/value_objects/chapter_id.dart';
import '../../../../shared/domain/value_objects/positive_int.dart';
import 'package:equatable/equatable.dart';

class ReadingState extends Equatable {
  final ReadingChapter? chapter;
  final bool isLoading;
  final String? error;
  final int currentPageIndex;

  const ReadingState({
    this.chapter,
    required this.isLoading,
    this.error,
    required this.currentPageIndex,
  });

  factory ReadingState.initial() {
    return const ReadingState(
      chapter: null,
      isLoading: false,
      error: null,
      currentPageIndex: 0,
    );
  }

  ReadingState copyWith({
    ReadingChapter? Function()? chapter,
    bool? isLoading,
    String? Function()? error,
    int? currentPageIndex,
  }) {
    return ReadingState(
      chapter: chapter != null ? chapter() : this.chapter,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
    );
  }

  @override
  List<Object?> get props => [chapter, isLoading, error, currentPageIndex];
}

class ReadingViewModel extends BaseStreamViewModel<ReadingState> {
  final ReadingRepository _repository;
  final ReadingProgressCoordinator _progressCoordinator;
  static const String _logTag = 'ReadingViewModel';

  ReadingViewModel(this._repository, this._progressCoordinator)
      : super(ReadingState.initial());

  ReadingChapter? get chapter => state.chapter;
  bool get isLoading => state.isLoading;
  String? get error => state.error;
  int get currentPageIndex => state.currentPageIndex;

  Future<void> loadChapter(String chapterId, {int? initialPage}) async {
    if (state.isLoading) return;
    AppLogger.i(
      'Loading chapter: $chapterId, initialPage: $initialPage',
      _logTag,
    );
    emit(state.copyWith(
      isLoading: true,
      error: () => null,
      currentPageIndex: initialPage ?? 0,
    ));

    try {
      final fetchedChapter = await _repository.getChapter(ChapterId(chapterId));
      AppLogger.i('Chapter loaded successfully: ${fetchedChapter.title?.value}', _logTag);
      final isTextChapter = fetchedChapter.contentType == ContentType.text;
      
      emit(state.copyWith(isLoading: false, chapter: () => fetchedChapter));
      saveProgress(completed: isTextChapter);
    } catch (e, stackTrace) {
      AppLogger.e('Error loading chapter', e, stackTrace, _logTag);
      emit(state.copyWith(isLoading: false, error: () => e.toString()));
    }
  }

  void setCurrentPage(int index, {bool isAutoSave = true}) {
    if (state.currentPageIndex != index) {
      emit(state.copyWith(currentPageIndex: index));

      if (isAutoSave && state.chapter != null) {
        final totalPages = state.chapter!.pages.length;
        final isLastPage = totalPages > 0 && index == totalPages - 1;
        saveProgress(completed: isLastPage);
      }
    }
  }

  Future<void> saveProgress({bool completed = false}) async {
    final chapterToSave = state.chapter;
    if (chapterToSave == null) return;

    try {
      await _progressCoordinator.saveProgress(
        chapterId: chapterToSave.id,
        bookId: chapterToSave.bookId,
        pageIndex: PositiveInt(state.currentPageIndex),
        totalPages: PositiveInt(chapterToSave.pages.length),
        completed: completed,
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error saving progress in ViewModel', e, stackTrace, _logTag);
    }
  }
}
