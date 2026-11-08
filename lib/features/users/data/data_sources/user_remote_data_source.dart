import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../domain/value_objects/profile_image_failure.dart';
import '../../domain/value_objects/profile_image_kind.dart';

/// Talks to the `/users/me` endpoints. Responses are unwrapped from the
/// API `{data: ...}` envelope into the profile JSON.
class UserRemoteDataSource {
  final Dio _dio;

  UserRemoteDataSource(this._dio);

  Future<Map<String, dynamic>> fetchMe() async {
    final response = await _dio.get<Map<String, dynamic>>('/users/me');
    return _unwrap(response.data);
  }

  Future<Map<String, dynamic>> uploadImage({
    required ProfileImageKind kind,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final mimeType = profileImageMimeType(fileName);
    if (mimeType == null) {
      throw ProfileImageFailure(
        ProfileImageFailureReason.unsupportedType,
        kind,
      );
    }
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: fileName,
        contentType: DioMediaType.parse(mimeType),
      ),
    });
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        kind.path,
        data: form,
        options: Options(
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      return _unwrap(response.data);
    } on DioException catch (e) {
      throw ProfileImageFailure(_reasonFor(e), kind);
    }
  }

  static ProfileImageFailureReason _reasonFor(DioException e) {
    // Connection-level errors have no response; any other status is the server's.
    switch (e.response?.statusCode) {
      case 400:
        return ProfileImageFailureReason.unsupportedType;
      case 413:
        return ProfileImageFailureReason.tooLarge;
      case 401:
      case 403:
        return ProfileImageFailureReason.forbidden;
      case null:
        return ProfileImageFailureReason.network;
      default:
        return ProfileImageFailureReason.unknown;
    }
  }

  static Map<String, dynamic> _unwrap(Map<String, dynamic>? body) {
    final data = body?['data'] ?? body;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Unexpected /users/me response');
    }
    return data;
  }
}
