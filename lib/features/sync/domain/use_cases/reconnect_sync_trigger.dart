import 'dart:async';

import '../../../../core/connectivity/connectivity_service.dart';
import 'app_sync_coordinator.dart';

/// Pushes what was saved offline (reading progress) as soon as the server is
/// reachable again.
class ReconnectSyncTrigger {
  final ConnectivityService _connectivity;
  final AppSyncCoordinator _coordinator;
  StreamSubscription<void>? _subscription;

  ReconnectSyncTrigger(this._connectivity, this._coordinator);

  void start() {
    _subscription ??= _connectivity.onReconnected.listen(
      (_) => _coordinator.sync(),
    );
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
