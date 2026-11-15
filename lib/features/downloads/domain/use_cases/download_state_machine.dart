import '../entities/download_state.dart';

/// What can happen to a chapter download.
enum DownloadEvent {
  /// The user paused it.
  pause,

  /// The user resumed it.
  resume,

  /// The user retried it.
  retry,

  /// One of its files started downloading.
  fileStarted,

  /// Its manifest or one of its files failed for good.
  fail,

  /// Its manifest and every file are on disk.
  complete,

  /// A planned chapter's files are gone (records restored without them).
  lost,
}

/// Transitions of a chapter download:
///
/// ```text
/// queued  -> running (fileStarted), paused, failed, done
/// running -> paused, failed, done
/// paused  -> queued (resume)
/// failed  -> queued (retry)
/// done    -> paused (lost)
/// running -> queued (lost)
/// ```
abstract final class DownloadStateMachine {
  /// The state after [event], or `null` when [event] does not apply to
  /// [state] (a late event from a cancelled file, a resume of a done chapter).
  static DownloadState? next(DownloadState state, DownloadEvent event) {
    return switch ((state, event)) {
      (DownloadState.queued, DownloadEvent.fileStarted) =>
        DownloadState.running,
      (DownloadState.queued || DownloadState.running, DownloadEvent.pause) =>
        DownloadState.paused,
      (DownloadState.queued || DownloadState.running, DownloadEvent.fail) =>
        DownloadState.failed,
      (DownloadState.queued || DownloadState.running, DownloadEvent.complete) =>
        DownloadState.done,
      (DownloadState.paused, DownloadEvent.resume) => DownloadState.queued,
      (DownloadState.failed, DownloadEvent.retry) => DownloadState.queued,
      (DownloadState.done, DownloadEvent.lost) => DownloadState.paused,
      // Its files are gone and it is planned again: nothing runs until then.
      (DownloadState.running, DownloadEvent.lost) => DownloadState.queued,
      _ => null,
    };
  }

  /// Whether the chapter still wants its files (queued or running).
  static bool isActive(DownloadState state) =>
      state == DownloadState.queued || state == DownloadState.running;
}
