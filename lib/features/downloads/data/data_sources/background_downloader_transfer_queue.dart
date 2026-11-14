import 'dart:async';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/logging/logger.dart';
import '../../domain/entities/download_state.dart';
import 'transfer_queue.dart';

/// Texts of the download notifications, already localized. `{numFinished}`,
/// `{numFailed}` and `{numTotal}` are filled in by the native side.
class DownloadNotificationTexts {
  final String runningTitle;
  final String runningBody;
  final String completeTitle;
  final String completeBody;
  final String errorTitle;
  final String errorBody;
  final String cancel;

  const DownloadNotificationTexts({
    required this.runningTitle,
    required this.runningBody,
    required this.completeTitle,
    required this.completeBody,
    required this.errorTitle,
    required this.errorBody,
    required this.cancel,
  });
}

/// [TransferQueue] on the `background_downloader` package: Android
/// WorkManager and iOS background URLSession, so files keep downloading when
/// the app is closed.
class BackgroundDownloaderTransferQueue implements TransferQueue {
  /// A file fails once this little would be left on the device.
  static const int minFreeMegabytes = 200;

  /// 3 tries in all.
  static const int retries = 2;

  static const String _notificationGroup = 'downloads';
  static const String _logTag = 'TransferQueue';

  final FileDownloader _downloader;
  final DownloadNotificationTexts Function() _texts;

  final StreamController<TransferEvent> _events =
      StreamController<TransferEvent>.broadcast();
  StreamSubscription<TaskUpdate>? _updates;
  bool _permissionAsked = false;

  BackgroundDownloaderTransferQueue({
    FileDownloader? downloader,
    required DownloadNotificationTexts Function() texts,
  }) : _downloader = downloader ?? FileDownloader(),
       _texts = texts;

  @override
  Stream<TransferEvent> get events => _events.stream;

  @override
  Future<void> start() async {
    _updates ??= _downloader.updates.listen(_onUpdate);
    await _downloader.configure(
      // No holding queue: it lives in the app process, so files waiting in
      // it are lost when the app is killed. WorkManager and URLSession
      // persist every task and pick their own concurrency. Set explicitly,
      // since the plugin persists configuration across launches.
      globalConfig: [
        (Config.holdingQueue, false),
        (Config.checkAvailableSpace, minFreeMegabytes),
      ],
      androidConfig: [(Config.useCacheDir, Config.never)],
      iOSConfig: [
        (Config.excludeFromCloudBackup, Config.always),
        (Config.localize, {'Cancel': _texts().cancel}),
      ],
    );
    _configureNotifications();
    await _downloader.resumeFromBackground();
  }

  void _configureNotifications() {
    final texts = _texts();
    // One notification for every download file, counting finished and failed
    // files across the group.
    _downloader.configureNotification(
      running: TaskNotification(texts.runningTitle, texts.runningBody),
      complete: TaskNotification(texts.completeTitle, texts.completeBody),
      error: TaskNotification(texts.errorTitle, texts.errorBody),
      progressBar: true,
      groupNotificationId: _notificationGroup,
    );
  }

  void _onUpdate(TaskUpdate update) {
    final event = eventOf(update);
    if (event != null && !_events.isClosed) _events.add(event);
  }

  /// The [TransferEvent] for a native update; `null` for progress and for
  /// intermediate states.
  @visibleForTesting
  static TransferEvent? eventOf(TaskUpdate update) {
    if (update is! TaskStatusUpdate) return null;
    final taskId = update.task.taskId;
    return switch (update.status) {
      TaskStatus.running => TransferStarted(taskId),
      TaskStatus.complete => TransferCompleted(taskId),
      TaskStatus.notFound => TransferFailed(taskId, DownloadErrors.notFound),
      TaskStatus.failed => TransferFailed(taskId, _errorOf(update.exception)),
      TaskStatus.canceled => TransferCancelled(taskId),
      TaskStatus.enqueued ||
      TaskStatus.waitingToRetry ||
      TaskStatus.paused => null,
    };
  }

  static String _errorOf(TaskException? exception) {
    return switch (exception) {
      TaskHttpException(httpResponseCode: 404) => DownloadErrors.notFound,
      TaskFileSystemException(:final description)
          when description.toLowerCase().contains('space') =>
        DownloadErrors.storageFull,
      TaskHttpException() || TaskConnectionException() => DownloadErrors.server,
      _ => DownloadErrors.unknown,
    };
  }

  @override
  Future<void> enqueue(List<FileTransfer> transfers) async {
    if (transfers.isEmpty) return;
    final results = await _downloader.enqueueAll([
      for (final t in transfers)
        DownloadTask(
          taskId: t.taskId,
          url: t.url,
          headers: t.headers,
          baseDirectory: BaseDirectory.applicationSupport,
          directory: t.directory,
          filename: t.filename,
          group: t.group,
          requiresWiFi: t.requiresWiFi,
          retries: retries,
          updates: Updates.status,
        ),
    ]);
    for (var i = 0; i < results.length; i++) {
      if (!results[i] && !_events.isClosed) {
        AppLogger.w('Could not enqueue a download file', _logTag);
        _events.add(
          TransferFailed(transfers[i].taskId, DownloadErrors.unknown),
        );
      }
    }
  }

  @override
  Future<void> cancel(Iterable<String> taskIds) async {
    final ids = taskIds.toList();
    if (ids.isEmpty) return;
    await _downloader.cancelTasksWithIds(ids);
  }

  @override
  Future<void> cancelAll() async {
    await cancel(await activeTaskIds());
  }

  @override
  Future<Set<String>> activeTaskIds() async {
    final ids = await _downloader.allTaskIds(allGroups: true);
    return ids.toSet();
  }

  @override
  Future<void> requestNotificationPermission() async {
    if (_permissionAsked) return;
    _permissionAsked = true;
    try {
      const type = PermissionType.notifications;
      if (await _downloader.permissions.status(type) !=
          PermissionStatus.granted) {
        await _downloader.permissions.request(type);
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Notification permission request failed',
        e,
        stackTrace,
        _logTag,
      );
    }
  }

  Future<void> dispose() async {
    await _updates?.cancel();
    await _events.close();
  }
}
