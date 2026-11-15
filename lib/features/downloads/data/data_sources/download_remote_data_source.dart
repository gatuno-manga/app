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

  /// A long chapter's manifest can take longer than the client's default
  /// receive timeout; a timeout here would read as "server unreachable".
  static const Duration manifestReceiveTimeout = Duration(seconds: 30);

  /// Statuses that say "try again later", not "this chapter is broken".
  static const Set<int> transientStatuses = {429, 502, 503, 504};

  /// The raw `GET /chapters/:id` response, stored as the chapter's manifest.
  ///
  /// Throws [ChapterUnavailableException] on 404, [TransientServerException]
  /// on a status in [transientStatuses], and the usual [AppExceptions]
  /// otherwise ([NetworkException] when unreachable).
  Future<Map<String, dynamic>> fetchManifest(String chapterId) async {
    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        '${ApiConstants.chapters}/$chapterId',
        options: Options(receiveTimeout: manifestReceiveTimeout),
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
      final status = e.response?.statusCode;
      if (status == 404) throw ChapterUnavailableException(chapterId);
      if (transientStatuses.contains(status)) {
        throw TransientServerException(status!);
      }
      throw ApiExceptionHandler.handle(e);
    }
  }

  /// [path] as the absolute URL Dio would request: page and document paths
  /// are often relative to the server. Dio appends the path to the base URL
  /// (keeping a base path such as `/api`), where `Uri.resolve` would replace
  /// it; the readers load the same paths through Dio.
  String resolve(String path) => RequestOptions(
    baseUrl: _dioClient.dio.options.baseUrl,
    path: path,
  ).uri.toString();

  /// Headers every file request carries. Files live under `/s3/`, which needs
  /// no auth, so there is no token to refresh.
  Map<String, String> get fileHeaders => {
    for (final entry in _dioClient.dio.options.headers.entries)
      if (entry.value is String) entry.key: entry.value as String,
  };
}
