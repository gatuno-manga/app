import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../logging/logger.dart';
import 'connectivity_service.dart';

/// Probes the server once; `true` when it answered, `false` when it did not,
/// `null` when there is nothing to probe yet (no server configured).
typedef ServerProbe = Future<bool?> Function();

/// [ConnectivityService] driven by server reachability.
///
/// The server is probed on [start], on every [triggers] event (device network
/// changes, app resume) and every [pollInterval] while offline. Requests
/// report their outcome through [reportReachable] and [reportUnreachable], so
/// a failed request flips the status at once instead of waiting for a probe.
class ServerConnectivityService implements ConnectivityService {
  final ServerProbe _probe;
  final Stream<void> _triggers;
  final Duration pollInterval;
  final Duration reconnectDebounce;

  static const String _logTag = 'ConnectivityService';

  final BehaviorSubject<ConnectivityStatus> _status =
      BehaviorSubject<ConnectivityStatus>.seeded(ConnectivityStatus.online);
  final StreamController<void> _reconnected =
      StreamController<void>.broadcast();

  StreamSubscription<void>? _triggerSubscription;
  Timer? _pollTimer;
  Timer? _reconnectTimer;
  Future<void>? _inFlightProbe;

  /// Set by a failed request until its confirming probe answers. If that
  /// probe finds the server up, the failure was a slow request, not an
  /// outage: the status goes back online without [onReconnected], so screens
  /// that reload on it do not retry the slow request in a loop.
  bool _confirmingFailure = false;

  ServerConnectivityService({
    required ServerProbe probe,
    Stream<void> triggers = const Stream<void>.empty(),
    this.pollInterval = const Duration(seconds: 30),
    this.reconnectDebounce = const Duration(seconds: 2),
  }) : _probe = probe,
       _triggers = triggers;

  @override
  ConnectivityStatus get status => _status.value;

  @override
  Stream<ConnectivityStatus> get statusStream => _status.stream.distinct();

  @override
  Stream<void> get onReconnected => _reconnected.stream;

  /// Starts listening to [triggers] and runs the first probe.
  Future<void> start() {
    _triggerSubscription ??= _triggers.listen((_) => checkNow());
    return checkNow();
  }

  @override
  void reportReachable() {
    // Any answer while a failure is being confirmed (the confirming probe's
    // own response included, since it goes through the same interceptor)
    // proves the outage was not real: back online without a reconnect.
    if (_confirmingFailure) {
      _confirmingFailure = false;
      _set(ConnectivityStatus.online, announceReconnect: false);
      return;
    }
    _set(ConnectivityStatus.online);
  }

  @override
  void reportUnreachable() {
    if (status == ConnectivityStatus.offline) return;
    _set(ConnectivityStatus.offline);
    // One slow request (the receive timeout is short) should not hold the app
    // offline until the next poll: confirm with a probe right away. A probe
    // already in flight is reused, so a failing probe does not loop.
    _confirmingFailure = true;
    checkNow();
  }

  @override
  Future<void> checkNow() =>
      _inFlightProbe ??= _runProbe().whenComplete(() => _inFlightProbe = null);

  // A probe that started before a request outcome may land after it and
  // override it; the next request or probe corrects that, so it is accepted.
  Future<void> _runProbe() async {
    bool? reachable;
    try {
      reachable = await _probe();
    } catch (e, stackTrace) {
      AppLogger.e('Connectivity probe failed', e, stackTrace, _logTag);
      reachable = false;
    }
    final falseAlarm = _confirmingFailure && reachable == true;
    _confirmingFailure = false;
    if (reachable == null) return;
    _set(
      reachable ? ConnectivityStatus.online : ConnectivityStatus.offline,
      announceReconnect: !falseAlarm,
    );
  }

  void _set(ConnectivityStatus next, {bool announceReconnect = true}) {
    if (_status.isClosed || _status.value == next) return;
    AppLogger.i('Server is now ${next.name}', _logTag);
    _status.add(next);

    if (next == ConnectivityStatus.offline) {
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
      _pollTimer ??= Timer.periodic(pollInterval, (_) => checkNow());
      return;
    }

    _pollTimer?.cancel();
    _pollTimer = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    if (!announceReconnect) return;
    _reconnectTimer = Timer(reconnectDebounce, () {
      _reconnectTimer = null;
      if (status == ConnectivityStatus.online && !_reconnected.isClosed) {
        _reconnected.add(null);
      }
    });
  }

  Future<void> dispose() async {
    _pollTimer?.cancel();
    _reconnectTimer?.cancel();
    await _triggerSubscription?.cancel();
    await _status.close();
    await _reconnected.close();
  }
}
