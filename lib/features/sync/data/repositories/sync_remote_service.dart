import '../../../../core/network/dio_client.dart';
import '../../../../core/logging/logger.dart';
import '../models/sync_dto.dart';

class SyncRemoteService {
  final DioClient _dioClient;
  static const String _logTag = 'SyncRemoteService';

  SyncRemoteService(this._dioClient);

  Future<SyncResultDto> syncData(SyncRequestDto request) async {
    AppLogger.d('Sending sync request', _logTag);
    try {
      final response = await _dioClient.dio.post<Map<String, dynamic>>(
        '/sync',
        data: request.toJson(),
      );

      if (response.data == null) {
        throw Exception('Empty response from /sync');
      }

      // Check if data is wrapped in envelope, if backend interceptor wraps it.
      // Usually DataEnvelopeInterceptor wraps success responses in { "data": ... }
      final responseData = response.data!['data'] ?? response.data;
      
      return SyncResultDto.fromJson(responseData as Map<String, dynamic>);
    } catch (e, stackTrace) {
      AppLogger.e('Error during unified sync via HTTP', e, stackTrace, _logTag);
      rethrow;
    }
  }
}
