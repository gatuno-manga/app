import 'package:equatable/equatable.dart';

/// One file for the native downloader.
class FileTransfer extends Equatable {
  /// Opaque to the queue; the caller makes it unique per attempt.
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

/// The native background downloader. Transfers keep running when the app is
/// closed.
///
/// Implemented today by an adapter over a third-party plugin, to be replaced
/// by the app's own plugin. What a consumer can rely on:
///
/// - Each file is written to [FileTransfer.directory] (relative to the
///   application support directory) under [FileTransfer.filename]; a file
///   on disk is complete.
/// - [start] runs first. Outcomes that happened while the app was not
///   running are not replayed as [events]: a finished file is on disk, a
///   failed or system-cancelled one is no longer in [activeTaskIds], and the
///   transfers the user cancelled (from a notification, say) are returned
///   by [start]. Once [start] returns, [activeTaskIds] is stable and the
///   consumer reconciles from it and the disk.
/// - After [start], [events] reports each task's outcome under its id, as it
///   happens. A [TransferCancelled] the consumer did not ask for came from
///   the user.
/// - [activeTaskIds] lists only this queue's queued or running tasks.
/// - [TransfersResynced] is emitted when tasks may have left the queue
///   without an event of their own.
abstract class TransferQueue {
  /// Outcomes of transfers, from [start] on.
  Stream<TransferEvent> get events;

  /// Configures the downloader and settles what happened while the app was
  /// not running. Returns the ids of transfers the user cancelled meanwhile.
  /// Listen to [events] first.
  Future<Set<String>> start();

  Future<void> enqueue(List<FileTransfer> transfers);

  Future<void> cancel(Iterable<String> taskIds);

  /// Cancels every download task of this queue, recorded or not.
  Future<void> cancelAll();

  /// Ids of transfers still queued or running natively.
  Future<Set<String>> activeTaskIds();

  /// Asks for permission to show download notifications, once.
  Future<void> requestNotificationPermission();
}
