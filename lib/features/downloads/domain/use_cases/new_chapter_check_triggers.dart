import 'dart:async';

import 'new_chapter_check.dart';

/// Runs the new-chapter check while the app is open: on start, then on every
/// [triggers] event (app resumed, server reachable again), unless a check
/// ran in the last [staleAfter].
class NewChapterCheckTriggers {
  /// Checks in the app are skipped when one ran this recently.
  static const Duration staleAfter = Duration(hours: 1);

  final NewChapterCheck _check;
  final Stream<void> _triggers;
  StreamSubscription<void>? _subscription;

  NewChapterCheckTriggers(this._check, {required Stream<void> triggers})
    : _triggers = triggers;

  void start() {
    if (_subscription != null) return;
    _subscription = _triggers.listen((_) => _run());
    _run();
  }

  void _run() => unawaited(_check.runIfStale(staleAfter));

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
