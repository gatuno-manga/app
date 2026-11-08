/// How long the app may stay in the background before the lock engages again.
enum AppLockGrace {
  immediately(Duration.zero),
  thirtySeconds(Duration(seconds: 30)),
  oneMinute(Duration(minutes: 1)),
  fiveMinutes(Duration(minutes: 5)),
  fifteenMinutes(Duration(minutes: 15));

  const AppLockGrace(this.duration);

  final Duration duration;

  static const AppLockGrace defaultValue = oneMinute;

  /// Resolves a persisted value; unknown or missing values use [defaultValue].
  static AppLockGrace fromSeconds(int? seconds) => values.firstWhere(
    (grace) => grace.duration.inSeconds == seconds,
    orElse: () => defaultValue,
  );
}
