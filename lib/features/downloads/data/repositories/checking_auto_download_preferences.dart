import 'dart:async';

import '../../../../core/logging/logger.dart';
import '../../../books/domain/value_objects/book_id.dart';
import '../../domain/entities/auto_download.dart';
import '../../domain/repositories/auto_download_preferences.dart';
import '../../domain/repositories/new_chapter_check_scheduler.dart';
import '../../domain/use_cases/new_chapter_check.dart';

/// [AutoDownloadPreferences] that keeps the new-chapter check in step with
/// the setting: turning it on checks the book at once, so the chapters it
/// has then are recorded as old while they still are, and the background
/// check is scheduled only while some book has it on.
class CheckingAutoDownloadPreferences implements AutoDownloadPreferences {
  /// How often the background check runs at most.
  static const Duration interval = Duration(hours: 6);

  static const String _logTag = 'CheckingAutoDownloadPreferences';

  final AutoDownloadPreferences _inner;
  final NewChapterCheck _check;
  final NewChapterCheckScheduler _scheduler;

  CheckingAutoDownloadPreferences(this._inner, this._check, this._scheduler);

  @override
  Stream<AutoDownload?> watch(BookId bookId) => _inner.watch(bookId);

  @override
  Future<void> enable(BookId bookId) async {
    await _inner.enable(bookId);
    unawaited(_check.run(only: bookId));
    unawaited(_guard(() => _scheduler.schedule(interval)));
  }

  @override
  Future<void> disable(BookId bookId) async {
    await _inner.disable(bookId);
    unawaited(syncSchedule());
  }

  @override
  Future<List<AutoDownload>> enabledBooks() => _inner.enabledBooks();

  /// Schedules the background check when some book has automatic download
  /// on, and cancels it otherwise (also after a server change wiped them).
  Future<void> syncSchedule() => _guard(() async {
    if ((await _inner.enabledBooks()).isEmpty) {
      await _scheduler.cancel();
    } else {
      await _scheduler.schedule(interval);
    }
  });

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (e, stackTrace) {
      AppLogger.e('Background check schedule failed', e, stackTrace, _logTag);
    }
  }
}
