import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/logging/logger.dart';

/// Whether the device is on Wi-Fi or Ethernet, for downloads restricted to
/// unmetered networks. Only labels a waiting download; the native downloader
/// enforces the rule itself.
class UnmeteredNetworkMonitor {
  static const String _logTag = 'UnmeteredNetworkMonitor';

  final BehaviorSubject<bool> _unmetered = BehaviorSubject<bool>.seeded(false);
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Stream<bool> get stream => _unmetered.stream.distinct();

  Future<void> start({Connectivity? connectivity}) async {
    final source = connectivity ?? Connectivity();
    _subscription ??= source.onConnectivityChanged.listen(
      _update,
      onError: (Object e, StackTrace stackTrace) =>
          AppLogger.e('Network type unavailable', e, stackTrace, _logTag),
    );
    try {
      _update(await source.checkConnectivity());
    } catch (e, stackTrace) {
      AppLogger.e('Network type unavailable', e, stackTrace, _logTag);
    }
  }

  void _update(List<ConnectivityResult> results) {
    if (_unmetered.isClosed) return;
    _unmetered.add(
      results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.ethernet),
    );
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _unmetered.close();
  }
}
