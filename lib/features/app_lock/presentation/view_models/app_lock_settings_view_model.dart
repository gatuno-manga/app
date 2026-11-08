import 'dart:async';

import '../../../../core/base/base_stream_view_model.dart';
import '../../domain/device_authenticator.dart';
import '../../domain/use_cases/app_lock_service.dart';
import '../../domain/value_objects/app_lock_grace.dart';

class AppLockSettingsViewModel extends BaseStreamViewModel<AppLockState> {
  final AppLockService _service;
  late final StreamSubscription<AppLockState> _subscription;

  AppLockSettingsViewModel(this._service) : super(_service.state) {
    _subscription = _service.stateStream.listen(emit);
  }

  Future<DeviceAuthOutcome> setEnabled(
    bool enabled, {
    required String reason,
  }) => _service.setEnabled(enabled, reason: reason);

  Future<void> setGrace(AppLockGrace grace) => _service.setGrace(grace);

  Future<void> setDeviceCredentialAllowed(bool allowed) =>
      _service.setDeviceCredentialAllowed(allowed);

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
