import 'dart:typed_data';
import 'dart:ui';

import '../../../../core/image/image_loading_strategy.dart';
import '../../../../core/image/image_size.dart';
import '../../../../core/logging/logger.dart';
import '../../../../core/network/api_constants.dart';
import '../../domain/repositories/downloaded_content.dart';

/// The first link of the image chain: a page image of a downloaded chapter
/// loads from disk, online or offline.
///
/// Anything else, and a downloaded file that is gone or unreadable, goes to
/// [_fallback] unchanged, so a chapter deleted while open keeps loading from
/// the network.
class DownloadedFileImageLoadingStrategy implements ImageLoadingStrategy {
  final DownloadedContent _downloads;
  final ImageLoadingStrategy _fallback;

  static const String _logTag = 'DownloadedFileImageLoadingStrategy';

  DownloadedFileImageLoadingStrategy(this._downloads, this._fallback);

  @override
  Future<Uint8List?> loadImage(
    String url, {
    void Function(Size)? onImageLoaded,
  }) async {
    final bytes = await _fromDisk(url, onImageLoaded);
    return bytes ?? _fallback.loadImage(url, onImageLoaded: onImageLoaded);
  }

  Future<Uint8List?> _fromDisk(
    String url,
    void Function(Size)? onImageLoaded,
  ) async {
    // Downloads only hold object-storage files: skip the lookup for the rest.
    if (!url.contains(ApiConstants.s3Prefix)) return null;
    try {
      final file = await _downloads.localFile(url);
      if (file == null) return null;
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return null;
      await reportImageSize(bytes, onImageLoaded);
      return bytes;
    } catch (e, stackTrace) {
      AppLogger.e('Could not read a downloaded image', e, stackTrace, _logTag);
      return null;
    }
  }
}
