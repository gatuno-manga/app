import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';

import '../logging/logger.dart';

/// Events that make the server worth probing again: the device network
/// changed, or the app came back to the foreground.
///
/// `connectivity_plus` is only a trigger: a network type says nothing about
/// whether the self-hosted server answers.
class ConnectivityTriggers {
  static const String _logTag = 'ConnectivityTriggers';

  final StreamController<void> _controller = StreamController<void>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _networkSubscription;
  AppLifecycleListener? _lifecycleListener;

  Stream<void> get stream => _controller.stream;

  void start({Connectivity? connectivity}) {
    _networkSubscription ??= (connectivity ?? Connectivity())
        .onConnectivityChanged
        .listen(
          (_) => _fire(),
          // No plugin (tests, unsupported platform): the probe and the
          // request outcomes still drive the status.
          onError: (Object e, StackTrace stackTrace) => AppLogger.e(
            'Network change events unavailable',
            e,
            stackTrace,
            _logTag,
          ),
        );
    _lifecycleListener ??= AppLifecycleListener(onResume: _fire);
  }

  void _fire() {
    if (!_controller.isClosed) _controller.add(null);
  }

  Future<void> dispose() async {
    _lifecycleListener?.dispose();
    await _networkSubscription?.cancel();
    await _controller.close();
  }
}
