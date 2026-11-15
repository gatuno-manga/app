/// Where a chapter download stands.
enum DownloadState { queued, running, paused, failed, done }

/// Why a [DownloadState.queued] or [DownloadState.running] chapter is not
/// making progress.
enum DownloadWaitReason { none, waitingForNetwork }

/// Codes stored in `ChapterDownload.error` for a failed chapter, so the UI
/// can map them to a localized message.
abstract final class DownloadErrors {
  /// The manifest request needs a session (HTTP 401).
  static const String signInRequired = 'signInRequired';

  /// Not enough free space on the device.
  static const String storageFull = 'storageFull';

  /// The server no longer has the chapter or one of its files.
  static const String notFound = 'notFound';

  /// A file took longer than the platform allows a background transfer
  /// (Android: 9 minutes per try).
  static const String timedOut = 'timedOut';

  /// The server answered with an error, or a file kept failing.
  static const String server = 'server';

  /// Anything else.
  static const String unknown = 'unknown';
}
