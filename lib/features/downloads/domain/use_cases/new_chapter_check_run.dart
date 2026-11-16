import 'dart:async';
import 'dart:io';

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

  /// How long a run may take from the moment the task starts: iOS gives a
  /// `BGAppRefreshTask` about 30 s, from which the engine's boot is taken
  /// too; Android WorkManager stops a worker at 10 min.
  static Duration get budget =>
      Platform.isIOS ? const Duration(seconds: 20) : const Duration(minutes: 8);

  /// Runs until done, [deadline], or [stopped] (the app asked for the
  /// database and the session). Never throws.
  Future<void> run({required DateTime deadline, Future<void>? stopped}) async {
    var stop = false;
    unawaited(stopped?.then((_) => stop = true));
    try {
      // The deadline bounds the whole run, also a native call that never
      // answers: the platform kills a task that overstays.
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
