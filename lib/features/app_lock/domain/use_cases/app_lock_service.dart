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
  /// Returns the prompt outcome; state only changes on
  /// [DeviceAuthOutcome.success]. Throws when the preference cannot be
  /// persisted: the outcome only ever describes the prompt.
  Future<DeviceAuthOutcome> setEnabled(
    bool enabled, {
    required DeviceAuthMessages messages,
  }) async {
    if (state.enabled == enabled) return DeviceAuthOutcome.success;

    final outcome = await _prompt(messages);
    if (outcome != DeviceAuthOutcome.success) return outcome;

    try {
      await _storage.setEnabled(enabled);
    } catch (e, stackTrace) {
      AppLogger.e('Error persisting app lock', e, stackTrace, _logTag);
      rethrow;
    }
    _emit(state.copyWith(enabled: enabled, locked: false));
    await _privacyScreen.setEnabled(enabled);
    AppLogger.i('App lock ${enabled ? 'enabled' : 'disabled'}', _logTag);
    return DeviceAuthOutcome.success;
  }

  Future<void> setGrace(AppLockGrace grace) async {
    await _storage.setGrace(grace);
    _emit(state.copyWith(grace: grace));
  }

  /// Refusing the device credential first proves a biometric works, so a
  /// PIN-only device can never lock itself out. Allowing it needs no prompt.
  Future<DeviceAuthOutcome> setDeviceCredentialAllowed(
    bool allowed, {
    required DeviceAuthMessages messages,
  }) async {
    if (!allowed) {
      final outcome = await _prompt(messages, allowDeviceCredential: false);
      if (outcome != DeviceAuthOutcome.success) return outcome;
    }
    await _storage.setDeviceCredentialAllowed(allowed);
    _emit(state.copyWith(deviceCredentialAllowed: allowed));
    return DeviceAuthOutcome.success;
  }

  /// Call when the app leaves the foreground.
  void onBackgrounded() {
    if (!state.enabled) return;
    _backgroundedAt = _clock();
  }

  /// Call when the app returns to the foreground; locks once the grace
  /// period has elapsed. Lifecycle churn caused by an open OS prompt
  /// (Android's device-credential screen pauses the activity) is ignored.
  void onForegrounded() {
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
  Future<DeviceAuthOutcome> unlock({required DeviceAuthMessages messages}) {
    if (!state.locked) return Future.value(DeviceAuthOutcome.success);
    return _inFlightUnlock ??= _runUnlock(
      messages,
    ).whenComplete(() => _inFlightUnlock = null);
  }

  Future<DeviceAuthOutcome> _runUnlock(DeviceAuthMessages messages) async {
    final outcome = await _prompt(messages);
    final success = outcome == DeviceAuthOutcome.success;
    _emit(
      state.copyWith(
        locked: !success,
        lastOutcome: () => success ? null : outcome,
      ),
    );
    return outcome;
  }

  Future<DeviceAuthOutcome> _prompt(
    DeviceAuthMessages messages, {
    bool? allowDeviceCredential,
  }) async {
    // Clearing the old outcome lets the cover re-announce an identical one.
    _emit(state.copyWith(isAuthenticating: true, lastOutcome: () => null));
    var outcome = DeviceAuthOutcome.failed;
    try {
      outcome = await _authenticator.authenticate(
        messages: messages,
        allowDeviceCredential:
            allowDeviceCredential ?? state.deviceCredentialAllowed,
      );
      return outcome;
    } finally {
      // A pass has no time away to count, whatever lifecycle churn the
      // prompt caused; any other outcome leaves the pause timestamp as
      // onBackgrounded/onForegrounded left it (Home pressed during the
      // prompt keeps it, so the grace period still applies on return).
      if (outcome == DeviceAuthOutcome.success) _backgroundedAt = null;
      _emit(state.copyWith(isAuthenticating: false));
    }
  }

  void _emit(AppLockState next) {
    if (!_stateSubject.isClosed) _stateSubject.add(next);
  }
}
