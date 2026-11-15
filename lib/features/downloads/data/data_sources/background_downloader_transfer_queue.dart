import 'dart:async';
import 'dart:io';

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
///
/// Temporary: the app's own downloader plugin will implement [TransferQueue]
/// and replace this adapter. Keep every plugin detail in this file and in
/// the injection.
class BackgroundDownloaderTransferQueue implements TransferQueue {
  /// A file fails once this little would be left on the device.
  static const int minFreeMegabytes = 200;

  /// 3 tries in all.
  static const int retries = 2;

  static const String _notificationGroup = 'downloads';

  /// Plugin group of every download task: what this queue lists, cancels
  /// and resumes, leaving any other use of the plugin alone.
  static const String group = 'gatuno.downloads';
  static const String _logTag = 'TransferQueue';

  /// How long to let paused updates settle before a resume sweep: the
  /// plugin records a paused task without waiting for the write.
  static const Duration resumeSettle = Duration(milliseconds: 500);

  final FileDownloader _downloader;
  final DownloadNotificationTexts Function() _texts;

  /// iOS: a task the system cancelled with resume data (a force-quit
  /// mid-file) is reported paused and waits for a resume from Dart. Android
  /// tasks never pause (no `allowPause`): a file still running at
  /// WorkManager's 9-minute limit fails and is retried from scratch. An
  /// interim limit of this adapter, until the app's own downloader plugin
  /// replaces it.
  final bool _resumesPausedTasks;

  /// Android: a cancel the app did not make, even one stored while the app
  /// was closed, came from the notification. iOS: cancels stored while the
  /// app was closed are the system's (a force-quit), and the grouped
  /// notification's Cancel never reaches the app.
  final bool _storedCancelsAreUsers;

  Future<void> _sweeps = Future<void>.value();
  Timer? _sweepTimer;

  final StreamController<TransferEvent> _events =
      StreamController<TransferEvent>.broadcast();
  StreamSubscription<TaskUpdate>? _updates;

  /// Set while [start] settles stored updates: they are not forwarded, and
  /// cancels among them are collected as the user's.
  Set<String>? _replayedUserCancels;
  bool _permissionAsked = false;

  BackgroundDownloaderTransferQueue({
    FileDownloader? downloader,
    required DownloadNotificationTexts Function() texts,
    bool? isIOS,
  }) : _downloader = downloader ?? FileDownloader(),
       _texts = texts,
       _resumesPausedTasks = isIOS ?? Platform.isIOS,
       _storedCancelsAreUsers = !(isIOS ?? Platform.isIOS);

  @override
  Stream<TransferEvent> get events => _events.stream;

  @override
  Future<Set<String>> start() async {
    final userCancels = _replayedUserCancels = <String>{};
    _updates ??= _downloader.updates.listen(_onUpdate);
    try {
      await _settleStoredUpdates();
    } catch (e, stackTrace) {
      // What was collected is still the user's, and paused iOS tasks still
      // need their resume: carry on rather than fail the whole start.
      AppLogger.e('Could not settle stored updates', e, stackTrace, _logTag);
      if (_resumesPausedTasks) await _sweep(notify: false);
    } finally {
      // Later updates must reach the consumer.
      _replayedUserCancels = null;
    }
    return userCancels;
  }

  Future<void> _settleStoredUpdates() async {
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
    if (_resumesPausedTasks) {
      // iOS creates the background session lazily, and only then delivers
      // the tasks the system cancelled with resume data (as paused). Open it
      // and let those callbacks land before the sweep; awaited, so the
      // caller's reconciliation sees the resumed tasks as active.
      await _downloader.allTaskIds(group: group);
      await Future<void>.delayed(resumeSettle);
      _sweepTimer?.cancel();
      // No resync event: the caller reconciles right after start.
      await _sweep(notify: false);
    }
    // Stored updates reach the listener asynchronously: let them land.
    await Future<void>.delayed(Duration.zero);
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
    final isStatus = update is TaskStatusUpdate;
    final status = isStatus ? update.status : null;
    if (status == TaskStatus.paused) {
      // Only iOS tasks pause (the system cancelled them with resume data);
      // Android tasks never allow pause.
      if (_resumesPausedTasks) {
        _sweepTimer?.cancel();
        _sweepTimer = Timer(resumeSettle, () => unawaited(_sweep()));
      }
      return;
    }
    final replayed = _replayedUserCancels;
    if (replayed != null) {
      // Settled by the consumer, not replayed. Android: the only cancels the
      // app does not make come from the notification. iOS: cancels during
      // start are the system's (a force-quit), and those files are queued
      // again.
      if (_storedCancelsAreUsers && status == TaskStatus.canceled) {
        replayed.add(update.task.taskId);
      }
      return;
    }
    final event = eventOf(update);
    if (event != null && !_events.isClosed) _events.add(event);
  }

  /// Resumes every paused task, one sweep at a time: the plugin removes a
  /// task from its paused list before resuming it, so serial sweeps never
  /// resume a task twice. A task without resume data is dropped by the
  /// plugin; the resync lets the owner queue it again.
  Future<void> _sweep({bool notify = true}) {
    return _sweeps = _sweeps.then((_) async {
      try {
        await _downloader.resumeAll(group: group);
      } catch (e, stackTrace) {
        AppLogger.e('Could not resume paused files', e, stackTrace, _logTag);
      }
      if (notify && !_events.isClosed) {
        _events.add(const TransfersResynced());
      }
    });
  }

  /// The [TransferEvent] for a native update; `null` for progress and for
  /// intermediate states. A pause is handled before this.
  @visibleForTesting
  static TaskTransferEvent? eventOf(TaskUpdate update) {
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
          // Both platforms say "Insufficient space to store the file...".
          when description.toLowerCase().contains('insufficient space') =>
        DownloadErrors.storageFull,
      // The plugin's exact text for WorkManager's 9-minute cut; a socket
      // timeout ("Read timed out") stays a server error.
      TaskConnectionException(:final description)
          when description == 'Task timed out' =>
        DownloadErrors.timedOut,
      TaskHttpException() || TaskConnectionException() => DownloadErrors.server,
      // WorkManager stopped the task (a lost network constraint, say).
      TaskException(:final description)
          when description.toLowerCase().contains('stopped by the system') =>
        DownloadErrors.server,
      _ => DownloadErrors.unknown,
    };
  }

  @override
  Future<void> enqueue(List<FileTransfer> transfers) async {
    if (transfers.isEmpty) return;
    final List<bool> results;
    try {
      results = await _downloader.enqueueAll([
        for (final t in transfers)
          DownloadTask(
            taskId: t.taskId,
            url: t.url,
            headers: t.headers,
            baseDirectory: BaseDirectory.applicationSupport,
            directory: t.directory,
            filename: t.filename,
            group: group,
            requiresWiFi: t.requiresWiFi,
            retries: retries,
            updates: Updates.status,
          ),
      ]);
    } catch (e, stackTrace) {
      // Reported per file, as a refused enqueue is: the chapters fail and can
      // be retried, instead of waiting on tasks that do not exist.
      AppLogger.e('Native enqueue failed', e, stackTrace, _logTag);
      for (final t in transfers) {
        if (!_events.isClosed) {
          _events.add(TransferFailed(t.taskId, DownloadErrors.unknown));
        }
      }
      return;
    }
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

  /// Waits for a running resume sweep: a task being resumed is briefly in
  /// neither of the plugin's lists.
  @override
  Future<Set<String>> activeTaskIds() async {
    await _sweeps;
    return (await _downloader.allTaskIds(group: group)).toSet();
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
    _sweepTimer?.cancel();
    await _updates?.cancel();
    await _events.close();
  }
}
