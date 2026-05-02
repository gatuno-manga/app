import 'dart:async';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import '../../data/database/reading_database.dart';
import '../../data/models/reading_progress_dto.dart';
import '../../data/repositories/reading_progress_local_service.dart';
import '../../data/repositories/reading_progress_remote_service.dart';
import '../../../authentication/domain/use_cases/auth_service.dart';
import '../../../settings/domain/use_cases/settings_service.dart';
import '../../../../core/logging/logger.dart';

class ReadingProgressCoordinator {
  final ReadingProgressLocalService _localService;
  final ReadingProgressRemoteService _remoteService;
  final AuthService _authService;
  final SettingsService _settingsService;
  static const String _logTag = 'ReadingProgressCoordinator';

  StreamSubscription<AuthEvent>? _authSubscription;
  StreamSubscription<RemoteReadingProgress>? _remoteSubscription;
  VoidCallback? _settingsListener;

  ReadingProgressCoordinator(
    this._localService,
    this._remoteService,
    this._authService,
    this._settingsService,
  ) {
    _init();
  }

  void _init() {
    // Listen to Auth changes
    _authSubscription = _authService.onAuthChange.listen((event) {
      if (event == AuthEvent.authenticated) {
        _handleLogin();
      } else if (event == AuthEvent.unauthenticated) {
        _handleLogout();
      }
    });

    // Listen to remote updates
    _remoteSubscription = _remoteService.onRemoteUpdate.listen((
      remoteProgress,
    ) {
      _handleRemoteUpdate(remoteProgress);
    });

    // Listen to settings changes (API URL)
    _settingsListener = () {
      if (_settingsService.apiUrl != null && _authService.authenticated) {
        _remoteService.disconnect();
        _remoteService.connect(_settingsService.apiUrl!);
      }
    };
    _settingsService.addListener(_settingsListener!);

    // Initial connection if already authenticated
    if (_authService.authenticated && _settingsService.apiUrl != null) {
      _remoteService.connect(_settingsService.apiUrl!);
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

      // 2. Sync migrated items to remote
      final dtos = guestProgress
          .map(
            (p) => SaveProgressDto(
              chapterId: p.chapterId,
              bookId: p.bookId,
              pageIndex: p.pageIndex,
              timestamp: p.timestamp.millisecondsSinceEpoch,
              totalPages: p.totalPages,
              completed: p.completed,
            ),
          )
          .toList();

      try {
        await _remoteService.syncBatch(SyncReadingProgressDto(progress: dtos));
      } catch (e) {
        AppLogger.w(
          'Failed to sync migrated guest progress to remote: $e',
          _logTag,
        );
      }
    }

    // 3. Connect WebSocket
    if (_settingsService.apiUrl != null) {
      _remoteService.connect(_settingsService.apiUrl!);
    }
  }

  void _handleLogout() {
    AppLogger.i('Handling logout in ReadingProgressCoordinator', _logTag);
    _remoteService.disconnect();
  }

  Future<void> _handleRemoteUpdate(RemoteReadingProgress remote) async {
    final currentUser = _authService.currentUser;
    if (currentUser.id.value != remote.userId) return;

    final local = await _localService.getProgress(
      remote.userId,
      remote.chapterId,
    );

    // Highest Page Wins
    if (local == null || remote.pageIndex >= local.pageIndex) {
      AppLogger.d(
        'Updating local progress from remote for chapter: ${remote.chapterId}',
        _logTag,
      );
      await _localService.saveProgress(
        ReadingProgressCompanion(
          id: Value(remote.id),
          userId: Value(remote.userId),
          chapterId: Value(remote.chapterId),
          bookId: Value(remote.bookId),
          pageIndex: Value(remote.pageIndex),
          timestamp: Value(remote.timestamp),
          version: Value(remote.version),
          totalPages: Value(remote.totalPages),
          completed: Value(remote.completed ?? false),
        ),
      );
    }
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
    final id = '${user.id.value}_$chapterId';

    // 1. Check local state (Highest Page Wins)
    final local = await _localService.getProgress(user.id.value, chapterId);
    if (local != null && pageIndex <= local.pageIndex && !completed) {
      return; // No need to update if we haven't progressed
    }

    // 2. Save locally
    final companion = ReadingProgressCompanion(
      id: Value(id),
      userId: Value(user.id.value),
      chapterId: Value(chapterId),
      bookId: Value(bookId),
      pageIndex: Value(pageIndex),
      timestamp: Value(timestamp),
      totalPages: Value(totalPages),
      completed: Value(completed),
    );
    await _localService.saveProgress(companion);

    // 3. Save remotely if authenticated
    if (!user.isGuest) {
      final dto = SaveProgressDto(
        chapterId: chapterId,
        bookId: bookId,
        pageIndex: pageIndex,
        timestamp: timestamp.millisecondsSinceEpoch,
        totalPages: totalPages,
        completed: completed,
      );
      try {
        await _remoteService.saveProgress(dto);
      } catch (e) {
        AppLogger.w(
          'Failed to save progress remotely, cached locally: $e',
          _logTag,
        );
      }
    }
  }

  void dispose() {
    _authSubscription?.cancel();
    _remoteSubscription?.cancel();
    if (_settingsListener != null) {
      _settingsService.removeListener(_settingsListener!);
    }
    _remoteService.dispose();
  }
}
