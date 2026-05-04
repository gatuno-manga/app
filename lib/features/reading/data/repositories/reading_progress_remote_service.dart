import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/logging/logger.dart';
import '../../../authentication/domain/use_cases/auth_service.dart';
import '../models/reading_progress_dto.dart';

class ReadingProgressRemoteService {
  final DioClient _dioClient;
  final AuthService _authService;
  static const String _logTag = 'ReadingProgressRemoteService';

  io.Socket? _socket;
  final _syncEventController =
      StreamController<RemoteReadingProgress>.broadcast();
  Stream<RemoteReadingProgress> get onRemoteUpdate =>
      _syncEventController.stream;

  ReadingProgressRemoteService(this._dioClient, this._authService);

  void connect(String baseUrl) async {
    final token = await _authService.getToken();
    if (token == null) {
      AppLogger.w('Cannot connect to WebSocket: No token available', _logTag);
      return;
    }

    final socketUrl = '$baseUrl/users/me/reading-progress';
    AppLogger.i('Connecting to WebSocket at: $socketUrl', _logTag);

    _socket = io.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {'token': token},
    });

    _socket?.onConnect((_) {
      AppLogger.i('WebSocket connected', _logTag);
      syncAll();
    });

    _socket?.onDisconnect(
      (_) => AppLogger.i('WebSocket disconnected', _logTag),
    );

    _socket?.on('progress:updated', (data) {
      AppLogger.d('Received remote progress update', _logTag);
      if (data != null && data is Map<String, dynamic>) {
        try {
          final progress = RemoteReadingProgress.fromJson(data);
          _syncEventController.add(progress);
        } catch (e) {
          AppLogger.e('Error parsing remote progress update', e, null, _logTag);
        }
      }
    });

    _socket?.on('progress:sync:complete', (data) {
      AppLogger.i('Received full sync data from remote', _logTag);
      if (data is List) {
        for (var item in data) {
          if (item is Map<String, dynamic>) {
            try {
              final progress = RemoteReadingProgress.fromJson(item);
              _syncEventController.add(progress);
            } catch (e) {
              AppLogger.e('Error parsing sync item', e, null, _logTag);
            }
          }
        }
      }
    });

    _socket?.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  Future<void> saveProgress(SaveProgressDto dto) async {
    if (_socket != null && _socket!.connected) {
      AppLogger.d('Sending progress update via WebSocket', _logTag);
      _socket?.emit('progress:update', dto.toJson());
    } else {
      AppLogger.d(
        'WebSocket disconnected, falling back to HTTP for progress save',
        _logTag,
      );
      try {
        await _dioClient.dio.post<void>(
          ApiConstants.readingProgress,
          data: dto.toJson(),
        );
      } catch (e, stackTrace) {
        AppLogger.e(
          'Error saving progress via HTTP fallback',
          e,
          stackTrace,
          _logTag,
        );
        rethrow;
      }
    }
  }

  void syncAll() {
    if (_socket != null && _socket!.connected) {
      AppLogger.i('Requesting full sync via WebSocket', _logTag);
      _socket?.emit('progress:sync');
    }
  }

  Future<void> syncBatch(SyncReadingProgressDto dto) async {
    try {
      await _dioClient.dio.post<void>(
        ApiConstants.readingProgressSync,
        data: dto.toJson(),
      );
    } catch (e, stackTrace) {
      AppLogger.e(
        'Error performing batch sync via HTTP',
        e,
        stackTrace,
        _logTag,
      );
      rethrow;
    }
  }

  void dispose() {
    _syncEventController.close();
    disconnect();
  }
}
