import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

import '../logging/logger.dart';
import '../network/dio_client.dart';
import 'file_cover_store.dart';

/// Downloads covers through [DioClient], bypassing the HTTP cache: the cover
/// store keeps its own copy, so a second one in the HTTP cache is waste.
CoverDownloader dioCoverDownloader(
  DioClient dioClient,
  CacheOptions httpCacheOptions,
) {
  final options = httpCacheOptions
      .copyWith(policy: CachePolicy.noCache)
      .toOptions()
      .copyWith(responseType: ResponseType.bytes);

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
