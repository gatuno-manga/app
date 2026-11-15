import 'package:equatable/equatable.dart';

/// One file for the native downloader.
class FileTransfer extends Equatable {
  /// Unique per attempt; see [TransferIds].
  final String taskId;
  final String url;
  final Map<String, String> headers;

  /// Directory relative to the application support directory.
  final String directory;
  final String filename;

  final bool requiresWiFi;

  const FileTransfer({
    required this.taskId,
    required this.url,
    this.headers = const {},
    required this.directory,
    required this.filename,
    this.requiresWiFi = false,
  });

  @override
  List<Object?> get props => [
    taskId,
    url,
    headers,
    directory,
    filename,
    requiresWiFi,
  ];
}

/// What happened in the native queue.
sealed class TransferEvent extends Equatable {
  const TransferEvent();
}

/// What happened to one native transfer.
sealed class TaskTransferEvent extends TransferEvent {
  final String taskId;

  const TaskTransferEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

/// Tasks may have left the native queue without an event of their own:
/// check which ones are still there.
class TransfersResynced extends TransferEvent {
  const TransfersResynced();

  @override
  List<Object?> get props => const [];
}

class TransferStarted extends TaskTransferEvent {
  const TransferStarted(super.taskId);
}

class TransferCompleted extends TaskTransferEvent {
  const TransferCompleted(super.taskId);
}

/// Failed for good, after the native retries.
class TransferFailed extends TaskTransferEvent {
  /// A `DownloadErrors` code.
  final String error;

  const TransferFailed(super.taskId, this.error);

  @override
  List<Object?> get props => [taskId, error];
}

/// Cancelled, by the app or from the notification.
class TransferCancelled extends TaskTransferEvent {
  const TransferCancelled(super.taskId);
}

/// Native task ids are `<fileId>@<session>.<attempt>`: a file enqueued
/// again (after a pause, a network rule change, or in a later app session)
/// gets a new id, so a late event from an earlier attempt cannot be
/// mistaken for the current one.
abstract final class TransferIds {
  static String forAttempt(String fileId, String session, int attempt) =>
      '$fileId@$session.$attempt';
}

/// The native background downloader. Transfers keep running when the app is
/// closed; their events are delivered when it runs again.
///
/// Implemented today by an adapter over a third-party plugin, to be replaced
/// by the app's own plugin. An implementation must: write each file to the
/// given directory under the application support directory; report each
/// task's outcome under its id (events may come after a restart); list in
/// [activeTaskIds] only its own queued or running tasks, stable once [start]
/// returns; and emit [TransfersResynced] when tasks may have left the queue
/// silently.
abstract class TransferQueue {
  /// Every event, including those that happened while the app was closed
  /// (delivered after [start]).
  Stream<TransferEvent> get events;

  /// Configures the downloader and replays events stored while the app was
  /// not running. Listen to [events] first.
  Future<void> start();

  Future<void> enqueue(List<FileTransfer> transfers);

  Future<void> cancel(Iterable<String> taskIds);

  /// Cancels every download task of this queue, recorded or not.
  Future<void> cancelAll();

  /// Ids of transfers still queued or running natively.
  Future<Set<String>> activeTaskIds();

  /// Asks for permission to show download notifications, once.
  Future<void> requestNotificationPermission();
}
