import '../../../../core/network/dio_client.dart';
import '../../../../core/logging/logger.dart';
import '../models/sync_dto.dart';
import '../../../../shared/domain/value_objects/timestamp.dart';

class SyncRemoteService {
  final DioClient _dioClient;
  static const String _logTag = 'SyncRemoteService';

  SyncRemoteService(this._dioClient);

  Future<void> pushData(PushSyncRequestDto request) async {
    AppLogger.d('Sending sync push request', _logTag);
    try {
      await _dioClient.dio.post<Map<String, dynamic>>(
        '/sync/push',
        data: request.toJson(),
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error during unified sync push via HTTP', e, stackTrace, _logTag);
      rethrow;
    }
  }

  Future<PullSyncResponseDto> pullData({Timestamp? lastSyncAt}) async {
    AppLogger.d('Sending sync pull request', _logTag);
    try {
      final queryParameters = <String, dynamic>{};
      if (lastSyncAt != null) {
        queryParameters['lastSyncAt'] = lastSyncAt.value.toIso8601String();
      }

      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        '/sync/pull',
        queryParameters: queryParameters,
      );

      if (response.data == null) {
        throw Exception('Empty response from /sync/pull');
      }

      final responseData = response.data!['data'] ?? response.data;
      return PullSyncResponseDto.fromJson(responseData as Map<String, dynamic>);
    } catch (e, stackTrace) {
      AppLogger.e('Error during unified sync pull via HTTP', e, stackTrace, _logTag);
      rethrow;
    }
  }
}
