/// How the book page shows downloads, derived from the download states.
library;

/// What a chapter's download indicator shows.
enum ChapterDownloadStatus {
  none,
  queued,
  running,
  waitingForNetwork,

  /// Active while the server is unreachable; wins over [waitingForNetwork].
  waitingForConnection,
  paused,
  failed,
  done,
}

/// The line under the summary strip's count, by priority.
enum BookDownloadPhase { active, waitingForConnection, paused, failed, done }
