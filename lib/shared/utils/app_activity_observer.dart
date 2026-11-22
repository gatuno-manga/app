import 'dart:async';
import 'package:flutter/material.dart';

/// A wrapper widget that tracks user interactions and app lifecycle.
///
/// It uses a [Listener] to detect pointer events and maintains a timer
/// to trigger [onIdle] when no interaction occurs for [idleTimeout].
/// It also triggers [onInteraction] when interaction resumes.
class AppActivityObserver extends StatefulWidget {
  final Widget child;
  final VoidCallback onInteraction;
  final VoidCallback onIdle;
  final Duration idleTimeout;

  const AppActivityObserver({
    super.key,
    required this.child,
    required this.onInteraction,
    required this.onIdle,
    this.idleTimeout = const Duration(minutes: 5),
  });

  @override
  State<AppActivityObserver> createState() => _AppActivityObserverState();
}

class _AppActivityObserverState extends State<AppActivityObserver>
    with WidgetsBindingObserver {
  Timer? _idleTimer;
  bool _isIdle = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resetIdleTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _idleTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Treat backgrounding as idleness for the purpose of timers
      _idleTimer?.cancel();
      _setIdle(true);
    } else if (state == AppLifecycleState.resumed) {
      // When resuming, we are no longer idle by default
      _setIdle(false);
      _resetIdleTimer();
    }
  }

  void _resetIdleTimer() {
    if (_isIdle) {
      _setIdle(false);
    }
    _idleTimer?.cancel();
    _idleTimer = Timer(widget.idleTimeout, () {
      _setIdle(true);
    });
  }

  void _setIdle(bool idle) {
    if (_isIdle != idle) {
      _isIdle = idle;
      if (_isIdle) {
        widget.onIdle();
      } else {
        widget.onInteraction();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetIdleTimer(),
      onPointerMove: (_) => _resetIdleTimer(),
      onPointerUp: (_) => _resetIdleTimer(),
      child: widget.child,
    );
  }
}
