import '../../../../core/connectivity/connectivity_service.dart';
import '../../../../core/logging/logger.dart';
import '../../../../core/network/exceptions.dart';
import '../../../authentication/domain/use_cases/auth_service.dart';
import '../../../books/domain/value_objects/chapter_id.dart';
import '../../../sync/domain/use_cases/pending_read_marks_flusher.dart';
import '../../../users/domain/value_objects/user_id.dart';
import '../repositories/pending_read_marks_repository.dart';
import '../repositories/reading_repository.dart';

/// Marks chapters as read on the server for signed-in users, queueing offline or
/// transient failures in [PendingReadMarksRepository] for later batch flush.
class ChapterReadMarkCoordinator implements PendingReadMarksFlusher {
  final ReadingRepository _repository;
  final PendingReadMarksRepository _pendingLocal;
  final AuthService _authService;
  final ConnectivityService _connectivity;
  static const String _logTag = 'ChapterReadMarkCoordinator';

  ChapterReadMarkCoordinator(
    this._repository,
    this._pendingLocal,
    this._authService,
    this._connectivity,
  );

  /// Fire-and-forget mark-read: never throws or blocks reading.
  Future<void> markRead(ChapterId chapterId) async {
    final user = _authService.currentUser;
    if (!_authService.authenticated || user.isGuest) return;

    if (_connectivity.isOffline) {
      await _enqueueSafely(user.id, chapterId);
      return;
    }

    try {
      await _repository.markChapterRead(chapterId);
    } on NetworkException catch (e, stackTrace) {
      AppLogger.w(
        'Network error marking chapter ${chapterId.value} read; queueing: $e',
        _logTag,
      );
      AppLogger.d('$stackTrace', _logTag);
      await _enqueueSafely(user.id, chapterId);
    } on ServerException catch (e, stackTrace) {
      final status = e.statusCode;
      if (status == null || status >= 500) {
        AppLogger.w(
          'Server error ($status) marking chapter ${chapterId.value} read; queueing',
          _logTag,
        );
        await _enqueueSafely(user.id, chapterId);
      } else {
        AppLogger.e(
          'Client error ($status) marking chapter ${chapterId.value} read; dropping',
          e,
          stackTrace,
          _logTag,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to mark chapter ${chapterId.value} read; dropping',
        e,
        stackTrace,
        _logTag,
      );
    }
  }

  @override
  Future<void> flushPending(UserId userId) async {
    final List<ChapterId> pending;
    try {
      pending = await _pendingLocal.getPendingChapterIds(userId);
    } catch (e, stackTrace) {
      AppLogger.e('Error reading pending read marks', e, stackTrace, _logTag);
      return;
    }
    if (pending.isEmpty) return;

    try {
      final results = await _repository.markChaptersRead(pending);
      final toClear = [
        for (final result in results)
          if (result.shouldClearFromQueue) result.chapterId,
      ];
      if (toClear.isNotEmpty) {
        await _pendingLocal.remove(userId, toClear);
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Error flushing ${pending.length} pending read marks',
        e,
        stackTrace,
        _logTag,
      );
    }
  }

  Future<void> _enqueueSafely(UserId userId, ChapterId chapterId) async {
    try {
      await _pendingLocal.enqueue(userId, chapterId);
    } catch (e, stackTrace) {
      AppLogger.e(
        'Error queueing pending read mark for ${chapterId.value}',
        e,
        stackTrace,
        _logTag,
      );
    }
  }
}
