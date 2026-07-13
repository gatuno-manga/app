import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../../features/authentication/domain/use_cases/auth_service.dart';
import '../../features/settings/domain/use_cases/settings_service.dart';
import '../../features/reading/data/models/reading_progress_dto.dart';
import '../logging/logger.dart';

class AppMqttService with WidgetsBindingObserver {
  final AuthService _authService;
  final SettingsService _settingsService;

  MqttServerClient? _client;
  static const String _logTag = 'AppMqttService';

  final _progressSyncedController =
      StreamController<RemoteReadingProgress>.broadcast();
  Stream<RemoteReadingProgress> get progressSyncedStream =>
      _progressSyncedController.stream;

  AppMqttService(this._authService, this._settingsService) {
    WidgetsBinding.instance.addObserver(this);
    _authService.authStateStream.listen((state) {
      if (state == AuthState.authenticated) {
        connect();
      } else if (state == AuthState.unauthenticated) {
        disconnect();
      }
    });

    // Connect initially if already authenticated
    if (_authService.authenticated) {
      connect();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      disconnect();
    } else if (state == AppLifecycleState.resumed) {
      if (_authService.authenticated) {
        connect();
      }
    }
  }

  Future<void> connect() async {
    if (_client != null &&
        _client!.connectionStatus!.state == MqttConnectionState.connected) {
      return;
    }

    final apiUrl = _settingsService.apiUrl;
    if (apiUrl == null) return;

    final uri = Uri.parse(apiUrl);
    final host = uri.host;

    final token = await _authService.getToken();
    if (token == null) return;

    final user = _authService.currentUser;
    if (user.isGuest) return;

    final clientId =
        'gatuno_app_${user.id.value}_${DateTime.now().millisecondsSinceEpoch}';

    _client = MqttServerClient.withPort(host, clientId, 8883)
      ..useWebSocket = false
      ..keepAlivePeriod = 20
      ..logging(on: false)
      ..onDisconnected = _onDisconnected
      ..onConnected = _onConnected
      ..onSubscribed = _onSubscribed
      ..pongCallback = _pong;

    final connMess = MqttConnectMessage()
      ..authenticateAs('jwt', token)
      ..withClientIdentifier(clientId)
      ..startClean()
      ..withWillQos(MqttQos.atLeastOnce);

    _client!.connectionMessage = connMess;

    try {
      AppLogger.i('Connecting to MQTT broker at $host:1883', _logTag);
      await _client!.connect();
    } catch (e) {
      AppLogger.e('Exception: $e', e, null, _logTag);
      disconnect();
    }

    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      AppLogger.i('MQTT client connected', _logTag);

      final topic = 'users/${user.id.value}/reading-progress';
      _client!.subscribe(topic, MqttQos.atLeastOnce);

      _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String pt = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );
        _handleMessage(c[0].topic, pt);
      });
    } else {
      AppLogger.w(
        'MQTT client connection failed - status is ${_client?.connectionStatus}',
        _logTag,
      );
      disconnect();
    }
  }

  void _handleMessage(String topic, String message) {
    try {
      final data = jsonDecode(message);
      if (data['event'] == 'progress:synced' ||
          data['event'] == 'progress.synced') {
        final payload = data['payload'] as Map<String, dynamic>;

        if (payload['success'] == true && payload['progress'] != null) {
          final progressJson = payload['progress'] as Map<String, dynamic>;
          final progress = RemoteReadingProgress.fromJson(progressJson);
          _progressSyncedController.add(progress);
        } else if (payload['id'] != null) {
          final progress = RemoteReadingProgress.fromJson(payload);
          _progressSyncedController.add(progress);
        }
      }
    } catch (e, stack) {
      AppLogger.e('Failed to parse MQTT message', e, stack, _logTag);
    }
  }

  void disconnect() {
    if (_client == null) return;
    AppLogger.i('Disconnecting MQTT', _logTag);
    try {
      _client?.disconnect();
    } catch (e) {
      AppLogger.e('Error disconnecting', e, null, _logTag);
    }
    _client = null;
  }

  void _onConnected() {
    AppLogger.i('MQTT Connected callback', _logTag);
  }

  void _onDisconnected() {
    AppLogger.i('MQTT Disconnected callback', _logTag);
  }

  void _onSubscribed(String topic) {
    AppLogger.i('MQTT Subscribed to $topic', _logTag);
  }

  void _pong() {
    AppLogger.d('MQTT Ping response client callback invoked', _logTag);
  }

  void disposeService() {
    WidgetsBinding.instance.removeObserver(this);
    disconnect();
    _progressSyncedController.close();
  }
}
