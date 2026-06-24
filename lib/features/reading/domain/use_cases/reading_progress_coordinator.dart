import 'dart:async';
import 'package:drift/drift.dart';
import '../../data/database/reading_database.dart';
import '../../data/repositories/reading_progress_local_service.dart';
import '../../../authentication/domain/use_cases/auth_service.dart';
import '../../../../core/logging/logger.dart';
import '../../../sync/domain/use_cases/app_sync_coordinator.dart';

class ReadingProgressCoordinator {
  final ReadingProgressLocalService _localService;
  final AppSyncCoordinator _syncCoordinator;
  final AuthService _authService;
  static const String _logTag = 'ReadingProgressCoordinator';

  StreamSubscription<AuthEvent>? _authSubscription;

  ReadingProgressCoordinator(
    this._localService,
    this._syncCoordinator,
    this._authService,
  ) {
    _init();
  }

  void _init() {
    // Listen to Auth changes
    _authSubscription = _authService.onAuthChange.listen((event) {
      if (event == AuthEvent.authenticated) {
        _handleLogin();
      }
    });

    // Initial sync if already authenticated
    if (_authService.authenticated) {
      _syncCoordinator.sync();
    }
  }

  Future<void> _handleLogin() async {
    final user = _authService.currentUser;
    if (user.isGuest) return;

    AppLogger.i(
      'Handling login in ReadingProgressCoordinator for user: ${user.id.value}',
      _logTag,
    );

    // 1. Migrate guest progress
    final guestProgress = await _localService.getAllGuestProgress();
    if (guestProgress.isNotEmpty) {
      AppLogger.i(
        'Migrating ${guestProgress.length} guest progress items',
        _logTag,
      );
      await _localService.updateProgressUserId('guest', user.id.value);
    }

    // 2. Trigger Unified Sync
    await _syncCoordinator.sync();
  }

  Future<void> saveProgress({
    required String chapterId,
    required String bookId,
    required int pageIndex,
    int? totalPages,
    bool completed = false,
  }) async {
    final user = _authService.currentUser;
    final timestamp = DateTime.now();

    // 1. Check local state (Highest Page Wins)
    final local = await _localService.getProgress(user.id.value, chapterId);

    int finalPageIndex = pageIndex;
    bool finalCompleted = completed;

    if (local != null && pageIndex < local.pageIndex && !completed) {
      // Keep the highest page index and completed status to avoid regressing progress
      finalPageIndex = local.pageIndex;
      finalCompleted = local.completed;
    }

    // 2. Save locally (Always update timestamp to mark as most recently accessed)
    final companion = ReadingProgressCompanion(
      userId: Value(user.id.value),
      chapterId: Value(chapterId),
      bookId: Value(bookId),
      pageIndex: Value(finalPageIndex),
      timestamp: Value(timestamp),
      totalPages: Value(totalPages ?? local?.totalPages),
      completed: Value(finalCompleted),
    );
    await _localService.saveProgress(companion);

    // 3. Trigger Sync
    if (!user.isGuest) {
      _syncCoordinator.sync(); // Fire and forget
    }
  }

  Future<ReadingProgressData?> getLastReadChapter(String bookId) async {
    final user = _authService.currentUser;
    AppLogger.d(
      'Coordinator: Getting last read chapter for book: $bookId, user: ${user.id.value}',
      _logTag,
    );
    return _localService.getLastReadChapter(user.id.value, bookId);
  }

  Future<List<ReadingProgressData>> getAllProgressForBook(String bookId) async {
    final user = _authService.currentUser;
    return _localService.getAllProgressForBook(user.id.value, bookId);
  }

  Future<List<String>> getContinueReadingBooks({int limit = 10}) async {
    final user = _authService.currentUser;
    if (user.isGuest) return [];
    
    AppLogger.d(
      'Coordinator: Getting continue reading books for user: ${user.id.value}',
      _logTag,
    );
    return _localService.getRecentUniqueBookIds(user.id.value, limit: limit);
  }

  void dispose() {
    _authSubscription?.cancel();
  }
}

