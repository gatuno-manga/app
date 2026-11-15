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

  final Workmanager _workmanager;
  final Function _dispatcher;
  Future<void>? _initialized;

  /// [dispatcher] is the top-level `@pragma('vm:entry-point')` function the
  /// background engine starts with.
  WorkmanagerCheckScheduler(this._dispatcher, {Workmanager? workmanager})
    : _workmanager = workmanager ?? Workmanager();

  Future<void> _initialize() =>
      _initialized ??= _workmanager.initialize(_dispatcher);

  @override
  Future<void> schedule(Duration interval) async {
    await _initialize();
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
  }

  @override
  Future<void> cancel() async {
    await _initialize();
    await _workmanager.cancelByUniqueName(taskId);
  }
}
