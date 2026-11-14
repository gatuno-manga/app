import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../logging/logger.dart';
import '../network/dio_client.dart';
import 'image_loading_strategy.dart';
import 'image_size.dart';

class DioImageLoadingStrategy implements ImageLoadingStrategy {
  final DioClient _dioClient;

  DioImageLoadingStrategy(this._dioClient);

  @override
  Future<Uint8List?> loadImage(
    String url, {
    void Function(Size)? onImageLoaded,
  }) async {
    try {
      final response = await _dioClient.dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.data != null) {
        final bytes = Uint8List.fromList(response.data!);

        await reportImageSize(bytes, onImageLoaded);

        return bytes;
      }
    } catch (e, s) {
      AppLogger.e('Error fetching image ($url)', e, s);
    }
    return null;
  }
}
