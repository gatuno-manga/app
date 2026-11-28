import 'package:dio/dio.dart';
import '../../../../core/connectivity/connectivity_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/exceptions.dart';
import '../../../../core/logging/logger.dart';
import '../../../books/domain/value_objects/chapter_id.dart';
import '../../../downloads/domain/entities/downloaded_chapter.dart';
import '../../../downloads/domain/repositories/downloaded_content.dart';
import '../../domain/entities/chapter_read_batch_result.dart';
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

  @override
  Future<void> markChapterRead(ChapterId chapterId) async {
    AppLogger.i('Marking chapter read: ${chapterId.value}', _logTag);
    await _guardRequest('marking chapter read', () async {
      await _dioClient.dio.post<dynamic>(
        '${ApiConstants.chapters}/${chapterId.value}/read',
      );
    });
  }

  @override
  Future<List<ChapterReadBatchResult>> markChaptersRead(
    List<ChapterId> chapterIds,
  ) async {
    if (chapterIds.isEmpty) return const [];
    AppLogger.i('Batch-marking ${chapterIds.length} chapters read', _logTag);
    return _guardRequest('batch-marking chapters read', () async {
      final response = await _dioClient.dio.post<dynamic>(
        ApiConstants.chaptersBatchRead,
        data: chapterIds.map((id) => id.value).toList(),
      );

      final raw = response.data;
      final List<dynamic>? items = switch (raw) {
        final List<dynamic> list => list,
        final Map<dynamic, dynamic> map when map['data'] is List<dynamic> =>
          map['data'] as List<dynamic>,
        _ => null,
      };
      if (items == null) {
        throw ServerException(
          message:
              'Failed to batch-mark chapters read: Invalid response format',
          statusCode: response.statusCode,
        );
      }

      return [
        for (final item in items)
          if (item is Map<dynamic, dynamic> && item['chapterId'] is String)
            ChapterReadBatchResult(
              chapterId: ChapterId(item['chapterId'] as String),
              success: item['success'] == true,
              error: item['error']?.toString(),
            ),
      ];
    });
  }

  Future<T> _guardRequest<T>(String action, Future<T> Function() run) async {
    try {
      return await run();
    } on AppExceptions {
      rethrow;
    } on DioException catch (e) {
      AppLogger.e(
        'DioException $action: ${e.message}',
        e,
        e.stackTrace,
        _logTag,
      );
      throw ApiExceptionHandler.handle(e);
    } catch (e, stackTrace) {
      AppLogger.e('Unexpected error $action', e, stackTrace, _logTag);
      throw Exception('An unexpected error occurred while $action');
    }
  }

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
