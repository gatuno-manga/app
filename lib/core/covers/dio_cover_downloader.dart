import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../logging/logger.dart';
import '../network/dio_client.dart';
import '../network/interceptors/cache_interceptor.dart';
import 'file_cover_store.dart';

/// Downloads covers through [DioClient], bypassing the HTTP cache: the cover
/// store keeps its own copy, so a second one in the HTTP cache is waste.
CoverDownloader dioCoverDownloader(DioClient dioClient) {
  final options = noHttpCacheOptions().copyWith(
    responseType: ResponseType.bytes,
  );

  return (url) async {
    try {
      final response = await dioClient.dio.get<List<int>>(
        url,
        options: options,
      );
      final data = response.data;
      return data == null ? null : Uint8List.fromList(data);
    } catch (e, stackTrace) {
      AppLogger.e('Error downloading cover', e, stackTrace, 'CoverDownloader');
      return null;
    }
  };
}
