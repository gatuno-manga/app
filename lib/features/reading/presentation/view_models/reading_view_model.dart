import '../../../../core/base/safe_change_notifier.dart';
import '../../../../core/logging/logger.dart';
import '../../domain/entities/reading_chapter.dart';
import '../../domain/repositories/reading_repository.dart';

class ReadingViewModel extends SafeChangeNotifier {
  final ReadingRepository _repository;
  static const String _logTag = 'ReadingViewModel';

  ReadingViewModel(this._repository);

  ReadingChapter? _chapter;
  ReadingChapter? get chapter => _chapter;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  int _currentPageIndex = 0;
  int get currentPageIndex => _currentPageIndex;

  Future<void> loadChapter(String chapterId, {int initialPage = 0}) async {
    AppLogger.i(
      'Loading chapter: $chapterId, initialPage: $initialPage',
      _logTag,
    );
    _isLoading = true;
    _error = null;
    _currentPageIndex = initialPage;
    notifyListeners();

    try {
      _chapter = await _repository.getChapter(chapterId);
      AppLogger.i('Chapter loaded successfully: ${_chapter?.title}', _logTag);
    } catch (e, stackTrace) {
      AppLogger.e('Error loading chapter', e, stackTrace, _logTag);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCurrentPage(int index) {
    if (_currentPageIndex != index) {
      _currentPageIndex = index;
      notifyListeners();
    }
  }
}
