import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

import '../../../domain/use_cases/app_lock_service.dart';
import '../../views/app_lock_screen.dart';

/// Covers [child] with [AppLockScreen] while the app is locked, feeds app
/// lifecycle into [AppLockService] and opens the OS prompt whenever the lock
/// engages or the app resumes still locked. Mount it in `MaterialApp.builder`
/// so it sits above the router (the route stack survives a lock) yet below
/// the localizations.
class AppLockGate extends StatefulWidget {
  final AppLockService service;
  final Widget child;

  const AppLockGate({super.key, required this.service, required this.child});

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  late final StreamSubscription<AppLockState> _subscription;
  late AppLockState _state;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _state = widget.service.state;
    _subscription = widget.service.stateStream.listen(_onState);
    if (_state.locked) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _prompt());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription.cancel();
    super.dispose();
  }

  void _onState(AppLockState next) {
    final engaged = next.locked && !_state.locked;
    if (next != _state) setState(() => _state = next);
    if (engaged) {
      // Offstage children keep focus, so the IME would stay open over the
      // cover and keystrokes would reach the hidden field.
      FocusManager.instance.primaryFocus?.unfocus();
      _prompt();
    }
  }

  void _prompt() {
    if (!mounted) return;
    final reason = AppLocalizations.of(context)!.appLockPromptReason;
    unawaited(widget.service.unlock(reason: reason));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        widget.service.onBackgrounded();
      case AppLifecycleState.resumed:
        widget.service.onForegrounded();
        final current = widget.service.state;
        // A prompt the system cancelled on backgrounding is offered again.
        if (current.locked && !current.isAuthenticating) _prompt();
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }

  /// Registered before the router's back dispatcher (this widget is its
  /// ancestor), so a locked app swallows the hardware back button.
  @override
  Future<bool> didPopRoute() async => widget.service.state.locked;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Offstage keeps the route stack alive but paints nothing beneath
        // the cover and drops it from semantics; ExcludeFocus keeps keyboard
        // input out of it.
        ExcludeFocus(
          excluding: _state.locked,
          child: Offstage(offstage: _state.locked, child: widget.child),
        ),
        if (_state.locked)
          AppLockScreen(
            isAuthenticating: _state.isAuthenticating,
            lastOutcome: _state.lastOutcome,
            onUnlock: _prompt,
          ),
      ],
    );
  }
}
