import '../../../../core/network/dio_client.dart';
import '../../../../core/logging/logger.dart';
import '../models/sync_dto.dart';
import '../../../../shared/domain/value_objects/timestamp.dart';

import '../../domain/repositories/sync_repository.dart';
import '../../domain/entities/syncable_entity.dart';
import '../../domain/value_objects/sync_feature_key.dart';
import '../../domain/entities/pull_sync_response.dart';
import '../../../reading/domain/entities/reading_progress.dart';
import '../../../reading/data/models/reading_progress_dto.dart';

class SyncRepositoryImpl implements SyncRepository {
  final DioClient _dioClient;
  static const String _logTag = 'SyncRepositoryImpl';

  SyncRepositoryImpl(this._dioClient);

  @override
  Future<void> pushData(Map<SyncFeatureKey, List<SyncableEntity>> payload) async {
    AppLogger.d('Sending sync push request', _logTag);
    
    List<SaveProgressDto>? readingProgress;
    
    if (payload.containsKey(SyncFeatureKey.readingProgress)) {
      final progressEntities = payload[SyncFeatureKey.readingProgress]!.cast<ReadingProgress>();
      readingProgress = progressEntities.map((e) => SaveProgressDto(
        chapterId: e.chapterId,
        bookId: e.bookId,
        pageIndex: e.pageIndex,
        timestamp: e.timestamp,
        totalPages: e.totalPages,
        completed: e.completed,
      )).toList();
    }
    
    final request = PushSyncRequestDto(
      readingProgress: readingProgress,
    );
    
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

  @override
  Future<PullSyncResponse> pullData({Timestamp? lastSyncAt}) async {
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
      final dto = PullSyncResponseDto.fromJson(responseData as Map<String, dynamic>);
      return PullSyncResponse(
        syncedAt: dto.syncedAt,
        data: dto.data,
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error during unified sync pull via HTTP', e, stackTrace, _logTag);
      rethrow;
    }
  }
}
