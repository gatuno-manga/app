import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'image_loading_strategy.dart';

/// A custom [ImageProvider] that uses an [ImageLoadingStrategy] to fetch image bytes.
///
/// This allows integrating custom loading logic (like Dio-based fetching)
/// directly into Flutter's image pipeline and caching system.
class StrategyImageProvider extends ImageProvider<StrategyImageProvider> {
  final String url;
  final ImageLoadingStrategy strategy;
  final void Function(Size)? onImageLoaded;

  const StrategyImageProvider({
    required this.url,
    required this.strategy,
    this.onImageLoaded,
  });

  @override
  Future<StrategyImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<StrategyImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    StrategyImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
      debugLabel: key.url,
      informationCollector:
          () => <DiagnosticsNode>[
            DiagnosticsProperty<ImageProvider>('Image provider', this),
            DiagnosticsProperty<StrategyImageProvider>('Image key', key),
          ],
    );
  }

  Future<ui.Codec> _loadAsync(
    StrategyImageProvider key,
    ImageDecoderCallback decode,
  ) async {
    final bytes = await strategy.loadImage(url, onImageLoaded: onImageLoaded);
    if (bytes == null || bytes.isEmpty) {
      throw StateError('Failed to load image bytes from $url');
    }
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    return decode(buffer);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is StrategyImageProvider &&
        other.url == url &&
        other.strategy == strategy;
  }

  @override
  int get hashCode => Object.hash(url, strategy);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'StrategyImageProvider')}(url: "$url", strategy: $strategy)';
}
