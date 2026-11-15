/// How the book page shows downloads, derived from the download states.
library;

import '../../domain/entities/chapter.dart';

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

/// What a chapter tile shows of its download.
class ChapterDownloadDisplay {
  final ChapterDownloadStatus status;

  /// From 0 to 1, for the ring.
  final double progress;

  const ChapterDownloadDisplay({required this.status, this.progress = 0});
}

/// The download controls of the chapter list, as plain data and callbacks.
class ChapterListDownloads {
  final ChapterDownloadDisplay Function(Chapter) displayOf;

  /// Selection mode: a tap toggles a chapter and indicators are
  /// display-only.
  final bool selecting;
  final bool Function(Chapter) isSelected;
  final void Function(Chapter) onToggleSelected;

  /// Long press outside selection mode: enters it with the chapter picked.
  final void Function(Chapter) onLongPress;
  final void Function(Chapter) onIndicatorTap;

  const ChapterListDownloads({
    required this.displayOf,
    required this.selecting,
    required this.isSelected,
    required this.onToggleSelected,
    required this.onLongPress,
    required this.onIndicatorTap,
  });
}
