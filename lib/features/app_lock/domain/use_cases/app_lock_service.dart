import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/logging/logger.dart';
import '../../data/data_sources/app_lock_local_data_source.dart';
import '../device_authenticator.dart';
import '../privacy_screen.dart';
import '../value_objects/app_lock_grace.dart';

class AppLockState extends Equatable {
  /// The device has a secure credential the lock can rely on.
  final bool isSupported;
  final bool enabled;
  final AppLockGrace grace;
  final bool deviceCredentialAllowed;
  final bool locked;

  /// An OS prompt is on screen; lifecycle churn it causes must be ignored.
  final bool isAuthenticating;

  /// Why the last unlock attempt did not succeed; null after a success.
  final DeviceAuthOutcome? lastOutcome;
  final bool isInitialized;

  const AppLockState({
    this.isSupported = false,
    this.enabled = false,
    this.grace = AppLockGrace.defaultValue,
    this.deviceCredentialAllowed = true,
    this.locked = false,
    this.isAuthenticating = false,
    this.lastOutcome,
    this.isInitialized = false,
  });

  AppLockState copyWith({
    bool? isSupported,
    bool? enabled,
    AppLockGrace? grace,
    bool? deviceCredentialAllowed,
    bool? locked,
    bool? isAuthenticating,
    DeviceAuthOutcome? Function()? lastOutcome,
    bool? isInitialized,
  }) => AppLockState(
    isSupported: isSupported ?? this.isSupported,
    enabled: enabled ?? this.enabled,
    grace: grace ?? this.grace,
    deviceCredentialAllowed:
        deviceCredentialAllowed ?? this.deviceCredentialAllowed,
    locked: locked ?? this.locked,
    isAuthenticating: isAuthenticating ?? this.isAuthenticating,
    lastOutcome: lastOutcome != null ? lastOutcome() : this.lastOutcome,
    isInitialized: isInitialized ?? this.isInitialized,
  );

  @override
  List<Object?> get props => [
    isSupported,
    enabled,
    grace,
    deviceCredentialAllowed,
    locked,
    isAuthenticating,
    lastOutcome,
    isInitialized,
  ];
}

/// Owns the app lock: its persisted preferences, the locked/unlocked state
/// driven by app lifecycle, and the OS prompts that change either.
class AppLockService {
  static const String _logTag = 'AppLockService';

  final AppLockStorage _storage;
  final DeviceAuthenticator _authenticator;
  final PrivacyScreen _privacyScreen;
  final DateTime Function() _clock;

  final _stateSubject = BehaviorSubject<AppLockState>.seeded(
    const AppLockState(),
  );
  DateTime? _backgroundedAt;
  bool _inBackground = false;
  Future<DeviceAuthOutcome>? _inFlightUnlock;

  AppLockService({
    required AppLockStorage storage,
    required DeviceAuthenticator authenticator,
    required PrivacyScreen privacyScreen,
    DateTime Function()? clock,
  }) : _storage = storage,
       _authenticator = authenticator,
       _privacyScreen = privacyScreen,
       _clock = clock ?? DateTime.now;

  Stream<AppLockState> get stateStream => _stateSubject.stream;
  AppLockState get state => _stateSubject.value;

  void dispose() {
    _stateSubject.close();
  }

  Future<void> init() async {
    if (state.isInitialized) return;
    var next = state;
    try {
      next = next.copyWith(
        enabled: await _storage.isEnabled(),
        grace: await _storage.getGrace(),
        deviceCredentialAllowed: await _storage.isDeviceCredentialAllowed(),
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error reading app lock settings', e, stackTrace, _logTag);
    }
    // The capability probe is separate on purpose: a failure there must not
    // switch off a lock the user enabled.
    next = next.copyWith(isSupported: await _probeSupport());
    _emit(next.copyWith(locked: next.enabled, isInitialized: true));
    await _privacyScreen.setEnabled(next.enabled);
  }

  Future<bool> _probeSupport() async {
    try {
      return await _authenticator.isDeviceSupported();
    } catch (e, stackTrace) {
      AppLogger.e('Error probing device support', e, stackTrace, _logTag);
      return false;
    }
  }

  /// The user may add or remove a screen lock while the app is away.
  Future<void> _refreshSupport() async {
    final supported = await _probeSupport();
    if (supported != state.isSupported) {
      _emit(state.copyWith(isSupported: supported));
    }
  }

  /// Turns the lock on or off after the user passes the OS prompt.
  /// Returns the prompt outcome; state only changes on [DeviceAuthOutcome.success].
  Future<DeviceAuthOutcome> setEnabled(
    bool enabled, {
    required String reason,
  }) async {
    if (state.enabled == enabled) return DeviceAuthOutcome.success;

    final outcome = await _prompt(reason);
    if (outcome != DeviceAuthOutcome.success) return outcome;

    try {
      await _storage.setEnabled(enabled);
    } catch (e, stackTrace) {
      AppLogger.e('Error persisting app lock', e, stackTrace, _logTag);
      return DeviceAuthOutcome.failed;
    }
    _backgroundedAt = null;
    _emit(state.copyWith(enabled: enabled, locked: false));
    await _privacyScreen.setEnabled(enabled);
    AppLogger.i('App lock ${enabled ? 'enabled' : 'disabled'}', _logTag);
    return DeviceAuthOutcome.success;
  }

  Future<void> setGrace(AppLockGrace grace) async {
    await _storage.setGrace(grace);
    _emit(state.copyWith(grace: grace));
  }

  Future<void> setDeviceCredentialAllowed(bool allowed) async {
    await _storage.setDeviceCredentialAllowed(allowed);
    _emit(state.copyWith(deviceCredentialAllowed: allowed));
  }

  /// Call when the app leaves the foreground.
  void onBackgrounded() {
    _inBackground = true;
    if (!state.enabled) return;
    _backgroundedAt = _clock();
  }

  /// Call when the app returns to the foreground; locks once the grace
  /// period has elapsed. Lifecycle churn caused by an open OS prompt
  /// (Android's device-credential screen pauses the activity) is ignored.
  void onForegrounded() {
    _inBackground = false;
    unawaited(_refreshSupport());
    final since = _backgroundedAt;
    _backgroundedAt = null;
    if (since == null || !state.enabled || state.isAuthenticating) return;
    final away = _clock().difference(since);
    if (away >= state.grace.duration) {
      AppLogger.i('App lock engaged after ${away.inSeconds}s away', _logTag);
      _emit(state.copyWith(locked: true));
    }
  }

  /// Shows the OS prompt and unlocks on success. Concurrent callers share
  /// the prompt already on screen.
  Future<DeviceAuthOutcome> unlock({required String reason}) {
    if (!state.locked) return Future.value(DeviceAuthOutcome.success);
    return _inFlightUnlock ??= _runUnlock(
      reason,
    ).whenComplete(() => _inFlightUnlock = null);
  }

  Future<DeviceAuthOutcome> _runUnlock(String reason) async {
    // Clearing the old outcome lets the cover re-announce an identical one.
    _emit(state.copyWith(lastOutcome: () => null));
    final outcome = await _prompt(reason);
    _emit(
      state.copyWith(
        locked: outcome != DeviceAuthOutcome.success,
        lastOutcome: () =>
            outcome == DeviceAuthOutcome.success ? null : outcome,
      ),
    );
    return outcome;
  }

  Future<DeviceAuthOutcome> _prompt(String reason) async {
    _emit(state.copyWith(isAuthenticating: true));
    try {
      return await _authenticator.authenticate(
        reason: reason,
        allowDeviceCredential: state.deviceCredentialAllowed,
      );
    } finally {
      // If the user really left (Home during the prompt) the timestamp set
      // on pause must survive so the grace period still applies on return.
      if (!_inBackground) _backgroundedAt = null;
      _emit(state.copyWith(isAuthenticating: false));
    }
  }

  void _emit(AppLockState next) {
    if (!_stateSubject.isClosed) _stateSubject.add(next);
  }
}
