import 'dart:typed_data';
import 'dart:ui';

import '../image/image_loading_strategy.dart';
import '../image/image_size.dart';
import '../logging/logger.dart';
import 'cover_store.dart';

/// Loads book covers through [CoverStore], so a cover seen once renders from
/// disk afterwards, offline included.
///
/// A URL that no cached book uses as its cover is not a managed cover and
/// goes to [_fallback] unchanged.
class CoverImageLoadingStrategy implements ImageLoadingStrategy {
  final CoverStore _store;
  final ImageLoadingStrategy _fallback;

  static const String _logTag = 'CoverImageLoadingStrategy';

  CoverImageLoadingStrategy(this._store, this._fallback);

  @override
  Future<Uint8List?> loadImage(
    String url, {
    void Function(Size)? onImageLoaded,
  }) async {
    try {
      final bookId = await _store.bookIdForUrl(url);
      if (bookId == null) {
        return await _fallback.loadImage(url, onImageLoaded: onImageLoaded);
      }
      final file = await _store.ensure(bookId, url);
      if (file == null) return null;
      final bytes = await file.readAsBytes();
      await reportImageSize(bytes, onImageLoaded);
      return bytes;
    } catch (e, stackTrace) {
      AppLogger.e('Error loading cover ($url)', e, stackTrace, _logTag);
      return null;
    }
  }
}
