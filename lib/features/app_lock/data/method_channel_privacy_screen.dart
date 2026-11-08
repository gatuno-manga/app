import 'package:flutter/services.dart';

import '../../../core/logging/logger.dart';
import '../domain/privacy_screen.dart';

class MethodChannelPrivacyScreen implements PrivacyScreen {
  static const String _logTag = 'PrivacyScreen';
  static const MethodChannel _channel = MethodChannel(
    'com.gatuno.app/privacy_screen',
  );

  @override
  Future<void> setEnabled(bool enabled) async {
    try {
      await _channel.invokeMethod<void>('setEnabled', {'enabled': enabled});
    } on MissingPluginException {
      // Platforms without the native cover (tests, desktop) simply skip it.
      AppLogger.w('Privacy screen not implemented on this platform', _logTag);
    } on PlatformException catch (e, stackTrace) {
      AppLogger.e('Privacy screen update failed', e, stackTrace, _logTag);
    }
  }
}
