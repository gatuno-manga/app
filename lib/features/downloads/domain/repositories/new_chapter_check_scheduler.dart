/// Runs the new-chapter check periodically while the app is not running.
///
/// The platform decides the exact time: [schedule] gives the shortest
/// interval between runs, not a promise.
abstract class NewChapterCheckScheduler {
  /// Schedules the periodic check every [interval], replacing an earlier
  /// schedule (also one with another interval).
  Future<void> schedule(Duration interval);

  /// Stops the periodic check.
  Future<void> cancel();
}
