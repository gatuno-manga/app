import 'dart:async';

import '../../../../core/logging/logger.dart';
import '../repositories/download_service.dart';
import 'await_planned.dart';
import 'new_chapter_check.dart';

/// One background run of the new-chapter check: checks every book, then
/// waits until the chapters it queued are planned, so their files are with
/// the native queue before the run ends. Planning needs the app; the files
/// then download without it.
class NewChapterCheckRun {
  static const String _logTag = 'NewChapterCheckRun';

  final NewChapterCheck _check;
  final DownloadService _downloads;

  NewChapterCheckRun(this._check, this._downloads);

  /// Runs until done, [deadline], or [stopped] (the app asked for the
  /// database and the session). Never throws.
  Future<void> run({required DateTime deadline, Future<void>? stopped}) async {
    var stop = false;
    unawaited(stopped?.then((_) => stop = true));
    try {
      // The deadline bounds the whole run, also a native call that never
      // answers: the platform kills a task that overstays. A check cut off
      // here is abandoned, not cancelled; at worst a chapter is queued but
      // not recorded, and the next check finds it downloading and records
      // it.
      final result = await _check
          .run(deadline: deadline, stopRequested: () => stop)
          .timeout(deadline.difference(DateTime.now()));
      await awaitPlanned(
        _downloads,
        result.queued,
        deadline: deadline,
        stopped: stopped,
      );
    } on TimeoutException {
      AppLogger.w('Ran out of time', _logTag);
    } catch (e, stackTrace) {
      AppLogger.e('Run failed', e, stackTrace, _logTag);
    }
  }
}
