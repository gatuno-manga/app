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

  /// The chapter the file belongs to.
  final String group;
  final bool requiresWiFi;

  const FileTransfer({
    required this.taskId,
    required this.url,
    this.headers = const {},
    required this.directory,
    required this.filename,
    required this.group,
    this.requiresWiFi = false,
  });

  @override
  List<Object?> get props => [
    taskId,
    url,
    headers,
    directory,
    filename,
    group,
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

/// Tasks may have left the native queue without an event of their own (a
/// paused task that could not resume): check which ones are still there.
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

  static final RegExp _format = RegExp(r'^.+/\d+@[0-9a-z]+\.\d+$');

  /// Whether [taskId] has the format of [forAttempt].
  static bool isDownloadTask(String taskId) => _format.hasMatch(taskId);
}

/// The native background downloader. Transfers keep running when the app is
/// closed; their events are delivered when it runs again.
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
