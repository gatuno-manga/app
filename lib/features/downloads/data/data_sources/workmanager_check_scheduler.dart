import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../../domain/repositories/new_chapter_check_scheduler.dart';

/// [NewChapterCheckScheduler] on the `workmanager` plugin: Android periodic
/// WorkManager work that needs a connected network, iOS `BGAppRefreshTask`
/// (the system picks the time; nothing runs after a force-quit).
///
/// The plugin is confined to this file and the background entry point, so
/// another scheduler can replace it.
class WorkmanagerCheckScheduler implements NewChapterCheckScheduler {
  /// The task's unique name; on iOS also the BGTaskScheduler identifier
  /// listed in Info.plist and registered in AppDelegate.
  static const String taskId = 'com.gatuno.app.newChapterCheck';

  /// The interval last registered, in seconds, to tell an interval change
  /// apart. Whether a task is pending is always asked of the platform: an
  /// iOS submit can fail silently (Background App Refresh off).
  static const String _intervalKey = 'new_chapter_check_interval';

  /// How long a run may take from the moment its task starts: iOS gives a
  /// `BGAppRefreshTask` about 30 s, from which the engine's boot is taken
  /// too; Android WorkManager stops a worker at 10 min.
  static Duration get budget =>
      Platform.isIOS ? const Duration(seconds: 20) : const Duration(minutes: 8);

  final Workmanager _workmanager;
  final void Function() _dispatcher;
  Future<void>? _initialized;

  /// [dispatcher] is the top-level `@pragma('vm:entry-point')` function the
  /// background engine starts with.
  WorkmanagerCheckScheduler(this._dispatcher, {Workmanager? workmanager})
    : _workmanager = workmanager ?? Workmanager();

  Future<void> _initialize() =>
      _initialized ??= _workmanager.initialize(_dispatcher);

  @override
  Duration get runBudget => budget;

  /// Registers only when no task is pending or the interval changed: iOS
  /// resubmits the next run 'interval from now' on every registration, so
  /// an app opened more often than that would never get a background run.
  @override
  Future<void> schedule(Duration interval) async {
    await _initialize();
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getInt(_intervalKey) == interval.inSeconds &&
        await _isPending()) {
      return;
    }
    await _workmanager.registerPeriodicTask(
      taskId,
      taskId,
      frequency: interval,
      // iOS re-submits each run with this delay, so it is the interval there.
      initialDelay: interval,
      constraints: Constraints(networkType: NetworkType.connected),
      // Keeps the running schedule, picking up a new interval.
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );
    await prefs.setInt(_intervalKey, interval.inSeconds);
  }

  Future<bool> _isPending() async {
    try {
      return await _workmanager.isScheduledByUniqueName(taskId);
    } catch (_) {
      // Unknown: registering again is the safe side.
      return false;
    }
  }

  @override
  Future<void> cancel() async {
    await _initialize();
    await _workmanager.cancelByUniqueName(taskId);
    await (await SharedPreferences.getInstance()).remove(_intervalKey);
  }
}
