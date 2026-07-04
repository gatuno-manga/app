import '../../../../core/network/app_mqtt_service.dart';
import '../../../../core/logging/logger.dart';
import '../../../authentication/domain/use_cases/auth_service.dart';
import '../../../sync/domain/use_cases/local_sync_feature_provider.dart';
import '../../domain/entities/reading_progress.dart';

class ReadingProgressMqttHandler {
  final AppMqttService _mqttService;
  final AuthService _authService;
  final LocalSyncFeatureProvider<ReadingProgress> _syncProvider;
  
  static const String _logTag = 'ReadingProgressMqttHandler';

  ReadingProgressMqttHandler(
    this._mqttService,
    this._authService,
    this._syncProvider,
  ) {
    _setupListener();
  }

  void _setupListener() {
    _mqttService.progressSyncedStream.listen((remote) async {
      AppLogger.i('Received reading progress sync via MQTT for chapter ${remote.chapterId.value}', _logTag);
      
      try {
        final user = _authService.currentUser;
        if (user.isGuest) return;
        
        // The provider expects a List<dynamic> of the raw JSON or parsed JSON.
        // Since we already have the DTO, we can convert it to JSON to reuse the provider's logic.
        await _syncProvider.processPulledData([remote.toJson()], user.id);
      } catch (e, stack) {
        AppLogger.e('Error processing MQTT progress sync', e, stack, _logTag);
      }
    });
  }
}
