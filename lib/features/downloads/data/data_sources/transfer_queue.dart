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

  /// Only over Wi-Fi (`DownloadNetwork.unmetered`).
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
///   on disk is complete. Where the platform needs it per file (iOS), the
///   queue keeps the files it writes out of device backups; elsewhere the
///   app's backup rules do (Android). The consumer heals records restored
///   without their files.
/// - [start] runs first. Outcomes that happened while the app was not
///   running are not replayed as [events]: a finished file is on disk, a
///   failed or system-cancelled one is no longer in [activeTaskIds], and the
///   transfers the user cancelled are returned by [start]. Once [start]
///   returns, [activeTaskIds] is complete and the consumer reconciles from
///   it and the disk. [start] does not fail for a stored update it cannot
///   read; [events] work after it either way.
/// - [activeTaskIds] lists every task of this queue that may still produce
///   its file or an outcome: queued, running, waiting to retry, or paused
///   for a later resume. A task left out may be enqueued again.
/// - After [start], [events] reports outcomes as they happen. A file is
///   tried 3 times (with backoff) before [TransferFailed]; its error is a
///   `DownloadErrors` code: `notFound` (HTTP 404), `storageFull` (less than
///   200 MB would remain), `timedOut` (the platform's per-try time limit,
///   Android's 9 minutes), `server` (other HTTP or connection errors,
///   network timeouts, the system stopping the task) or `unknown` (anything
///   else, including connection failures the platform does not classify).
/// - [enqueue] never throws: a refused or failed enqueue is reported as
///   [TransferFailed] for each file. [cancel], [cancelAll] and
///   [requestNotificationPermission] never throw either: failures are
///   logged, and a task a cancel misses is cancelled later as an orphan.
///   [activeTaskIds] may throw; the consumer then keeps its bindings.
/// - [cancel] of an unknown or finished id does nothing. Cancels the
///   consumer makes may or may not produce [TransferCancelled]; the consumer
///   unbinds the ids first. A [TransferCancelled] the consumer did not ask
///   for came from the user.
/// - [TransfersResynced] is emitted when tasks may have left the queue
///   without an event of their own.
/// - Progress is shown in one grouped system notification while the app is
///   in the background.
abstract class TransferQueue {
  /// Outcomes of transfers, from [start] on.
  Stream<TransferEvent> get events;

  /// Configures the downloader and settles what happened while the app was
  /// not running. Returns the ids of transfers the user cancelled meanwhile.
  /// Listen to [events] first.
  Future<Set<String>> start();

  Future<void> enqueue(List<FileTransfer> transfers);

  Future<void> cancel(Iterable<String> taskIds);

  /// Cancels every download task of this queue.
  Future<void> cancelAll();

  /// Every task of this queue that may still produce its file or an
  /// outcome: queued, running, waiting to retry, or paused for a resume.
  Future<Set<String>> activeTaskIds();

  /// Asks for permission to show download notifications, once.
  Future<void> requestNotificationPermission();
}
