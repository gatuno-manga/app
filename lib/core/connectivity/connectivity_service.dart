/// Whether the configured server can be reached.
///
/// "Online" means the server answers, not merely that the device has a
/// network: a phone on Wi-Fi away from a self-hosted server is offline.
enum ConnectivityStatus { online, offline }

/// Reachability of the configured server, for view models and repositories.
///
/// View models subscribe to [statusStream] to show the offline indicator and
/// to [onReconnected] to reload their data. Repositories read [status] to
/// skip the network while offline.
abstract class ConnectivityService {
  /// The current status. Starts as [ConnectivityStatus.online] until the
  /// first probe or request says otherwise.
  ConnectivityStatus get status;

  /// Emits the current status on listen, then every change.
  Stream<ConnectivityStatus> get statusStream;

  /// Emits once per offline-to-online transition, after the link has stayed
  /// online for a short debounce, so a flapping link does not fire repeatedly.
  Stream<void> get onReconnected;

  /// A request reached the server.
  void reportReachable();

  /// A request failed to reach the server (connection error or timeout).
  void reportUnreachable();

  /// Probes the server now and updates [status] with the result.
  Future<void> checkNow();
}

extension ConnectivityServiceStatus on ConnectivityService {
  bool get isOffline => status == ConnectivityStatus.offline;
}
