import 'dart:typed_data';
import 'package:flutter/material.dart';

abstract interface class ImageLoadingStrategy {
  Future<Uint8List?> loadImage(
    String url, {
    void Function(Size)? onImageLoaded,
  });
}
