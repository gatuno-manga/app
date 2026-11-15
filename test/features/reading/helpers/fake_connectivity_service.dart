import 'dart:async';

import 'package:gatuno/core/connectivity/connectivity_service.dart';

/// A [ConnectivityService] the test drives by hand.
class FakeConnectivityService implements ConnectivityService {
  final _statuses = StreamController<ConnectivityStatus>.broadcast();
  final _reconnects = StreamController<void>.broadcast();
  ConnectivityStatus _status;

  /// What [checkNow] finds.
  ConnectivityStatus probeResult = ConnectivityStatus.offline;
  int checks = 0;

  FakeConnectivityService({
    ConnectivityStatus status = ConnectivityStatus.online,
  }) : _status = status;

  @override
  ConnectivityStatus get status => _status;

  /// Like the real service: the current status on listen, then changes.
  @override
  Stream<ConnectivityStatus> get statusStream async* {
    yield _status;
    yield* _statuses.stream;
  }

  @override
  Stream<void> get onReconnected => _reconnects.stream;

  void _set(ConnectivityStatus value) {
    _status = value;
    _statuses.add(value);
  }

  void goOffline() => _set(ConnectivityStatus.offline);

  void reconnect() {
    _set(ConnectivityStatus.online);
    _reconnects.add(null);
  }

  @override
  void reportReachable() => _set(ConnectivityStatus.online);

  @override
  void reportUnreachable() => _set(ConnectivityStatus.offline);

  @override
  Future<void> checkNow() async {
    checks++;
    _set(probeResult);
  }

  Future<void> close() async {
    await _statuses.close();
    await _reconnects.close();
  }
}
