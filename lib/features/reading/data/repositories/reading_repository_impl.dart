import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/exceptions.dart';
import '../../../../core/logging/logger.dart';
import '../../../books/domain/value_objects/chapter_id.dart';
import '../../domain/repositories/reading_repository.dart';
import '../models/reading_chapter_model.dart';

class ReadingRepositoryImpl implements ReadingRepository {
  final DioClient _dioClient;
  static const String _logTag = 'ReadingRepository';

  ReadingRepositoryImpl(this._dioClient);

  @override
  Future<ReadingChapterModel> getChapter(ChapterId chapterId) async {
    AppLogger.i('Fetching chapter details for ID: ${chapterId.value}', _logTag);
    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        '${ApiConstants.chapters}/${chapterId.value}',
      );

      final data = response.data;
      if (response.statusCode == 200 && data is Map<String, dynamic>) {
        return ReadingChapterModel.fromJson(data);
      } else {
        throw ServerException(
          message: 'Failed to fetch chapter: Invalid response format',
          statusCode: response.statusCode,
        );
      }
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      AppLogger.e(
        'DioException fetching chapter: ${e.message}',
        e,
        e.stackTrace,
        _logTag,
      );
      throw ApiExceptionHandler.handle(e);
    } catch (e, stackTrace) {
      AppLogger.e('Unexpected error fetching chapter', e, stackTrace, _logTag);
      throw Exception('An unexpected error occurred while fetching chapter');
    }
  }
}
