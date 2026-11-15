import 'package:dio/dio.dart';
import '../../../../core/connectivity/connectivity_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/exceptions.dart';
import '../../../../core/logging/logger.dart';
import '../../../books/domain/value_objects/chapter_id.dart';
import '../../../downloads/domain/entities/downloaded_chapter.dart';
import '../../../downloads/domain/repositories/downloaded_content.dart';
import '../../domain/entities/opened_chapter.dart';
import '../../domain/entities/reading_chapter.dart';
import '../../domain/repositories/reading_repository.dart';
import '../models/reading_chapter_model.dart';

class ReadingRepositoryImpl implements ReadingRepository {
  final DioClient _dioClient;
  final DownloadedContent _downloads;
  final ConnectivityService _connectivity;
  static const String _logTag = 'ReadingRepository';

  ReadingRepositoryImpl(this._dioClient, this._downloads, this._connectivity);

  @override
  Future<OpenedChapter> openChapter(ChapterId chapterId) async {
    final downloaded = await _downloaded(chapterId);
    if (downloaded != null) {
      AppLogger.i('Opening downloaded chapter ${chapterId.value}', _logTag);
      return OpenedChapter(chapter: downloaded.chapter, isDownloaded: true);
    }
    // Known offline: skip the connect timeout.
    if (_connectivity.isOffline) throw OfflineException();
    try {
      return OpenedChapter(
        chapter: await _fetch(chapterId),
        isDownloaded: false,
      );
    } on NetworkException {
      throw OfflineException();
    }
  }

  @override
  Future<ReadingChapter> refreshNavigation(ReadingChapter chapter) async {
    final remote = await _fetch(chapter.id);
    final saved = chapter.updatedAt?.value;
    final current = remote.updatedAt?.value;
    if (saved != null && current != null && current.isAfter(saved)) {
      AppLogger.i(
        'Chapter ${chapter.id.value} changed on the server after it was '
        'downloaded',
        _logTag,
      );
    }
    return chapter.withNeighbours(previous: remote.previous, next: remote.next);
  }

  @override
  Future<bool> isDownloaded(ChapterId chapterId) async =>
      await _downloaded(chapterId) != null;

  /// A broken download must not keep a chapter from opening: the server
  /// answers instead.
  Future<DownloadedChapter?> _downloaded(ChapterId chapterId) async {
    try {
      return await _downloads.chapter(chapterId);
    } catch (e, stackTrace) {
      AppLogger.e('Could not read a download', e, stackTrace, _logTag);
      return null;
    }
  }

  Future<ReadingChapterModel> _fetch(ChapterId chapterId) async {
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
    } on AppExceptions {
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
