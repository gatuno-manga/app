import 'package:dio/dio.dart';

import '../../../../core/logging/logger.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/exceptions.dart';
import '../../exceptions/download_exceptions.dart';

/// Server side of downloads: chapter manifests, and what the native
/// downloader needs to fetch files without Dio.
class DownloadRemoteDataSource {
  final DioClient _dioClient;

  static const String _logTag = 'DownloadRemoteDataSource';

  DownloadRemoteDataSource(this._dioClient);

  /// The raw `GET /chapters/:id` response, stored as the chapter's manifest.
  Future<Map<String, dynamic>> fetchManifest(String chapterId) async {
    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        '${ApiConstants.chapters}/$chapterId',
      );
      final data = response.data;
      if (data == null) {
        throw ServerException(
          message: 'Empty chapter response',
          statusCode: response.statusCode,
        );
      }
      return data;
    } on DioException catch (e) {
      AppLogger.e('Could not fetch chapter manifest', e, e.stackTrace, _logTag);
      // ApiExceptionHandler maps 404 to an AuthException; downloads need to
      // tell a missing chapter apart.
      if (e.response?.statusCode == 404) {
        throw ChapterUnavailableException(chapterId);
      }
      throw ApiExceptionHandler.handle(e);
    }
  }

  /// [path] as an absolute URL: page and document paths are often relative
  /// to the server.
  String resolve(String path) =>
      Uri.parse(_dioClient.dio.options.baseUrl).resolve(path).toString();

  /// Headers every file request carries. Files live under `/s3/`, which needs
  /// no auth, so there is no token to refresh.
  Map<String, String> get fileHeaders => {
    for (final entry in _dioClient.dio.options.headers.entries)
      if (entry.value is String) entry.key: entry.value as String,
  };
}
