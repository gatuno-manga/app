import 'dart:async';

import 'package:flutter/widgets.dart';

/// Fires each time the app comes back to the foreground, for work that
/// should catch up then (the new-chapter check).
class AppResumes {
  final StreamController<void> _controller = StreamController<void>.broadcast();
  late final AppLifecycleListener _listener;

  AppResumes() {
    _listener = AppLifecycleListener(
      onResume: () {
        if (!_controller.isClosed) _controller.add(null);
      },
    );
  }

  Stream<void> get stream => _controller.stream;

  Future<void> dispose() async {
    _listener.dispose();
    await _controller.close();
  }
}
