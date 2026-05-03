import '../../../../core/base/safe_change_notifier.dart';
import '../../../../core/logging/logger.dart';
import '../../domain/entities/reading_chapter.dart';
import '../../domain/entities/reading_enums.dart';
import '../../domain/repositories/reading_repository.dart';
import '../../domain/use_cases/reading_progress_coordinator.dart';

class ReadingViewModel extends SafeChangeNotifier {
  final ReadingRepository _repository;
  final ReadingProgressCoordinator _progressCoordinator;
  static const String _logTag = 'ReadingViewModel';

  ReadingViewModel(this._repository, this._progressCoordinator);

  ReadingChapter? _chapter;
  ReadingChapter? get chapter => _chapter;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  int _currentPageIndex = 0;
  int get currentPageIndex => _currentPageIndex;

  Future<void> loadChapter(String chapterId, {int? initialPage}) async {
    if (_isLoading) return;
    AppLogger.i(
      'Loading chapter: $chapterId, initialPage: $initialPage',
      _logTag,
    );
    _isLoading = true;
    _error = null;
    _currentPageIndex = initialPage ?? 0;
    notifyListeners();

    try {
      _chapter = await _repository.getChapter(chapterId);
      AppLogger.i('Chapter loaded successfully: ${_chapter?.title}', _logTag);
      final isTextChapter = _chapter?.contentType == ContentType.text;
      saveProgress(completed: isTextChapter);
    } catch (e, stackTrace) {
      AppLogger.e('Error loading chapter', e, stackTrace, _logTag);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCurrentPage(int index, {bool isAutoSave = true}) {
    if (_currentPageIndex != index) {
      _currentPageIndex = index;
      notifyListeners();

      if (isAutoSave && _chapter != null) {
        final totalPages = _chapter!.pages.length;
        final isLastPage = totalPages > 0 && index == totalPages - 1;
        saveProgress(completed: isLastPage);
      }
    }
  }

  Future<void> saveProgress({bool completed = false}) async {
    final chapter = _chapter;
    if (chapter == null) return;

    try {
      await _progressCoordinator.saveProgress(
        chapterId: chapter.id,
        bookId: chapter.bookId,
        pageIndex: _currentPageIndex,
        totalPages: chapter.pages.length,
        completed: completed,
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error saving progress in ViewModel', e, stackTrace, _logTag);
    }
  }
}
