import 'package:flutter/material.dart';

import '../../../../core/image/image_loading_strategy.dart';
import '../../../../core/image/strategy_image_provider.dart';
import 'app_image_placeholder.dart';

/// A widget that displays an image using a custom [ImageLoadingStrategy].
///
/// It handles placeholders, error states, and smooth transitions (fading)
/// between the placeholder/blurhash and the final image.
class AppImage extends StatelessWidget {
  final String imageUrl;
  final String? blurHash;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final void Function(Size)? onImageLoaded;
  final ImageLoadingStrategy strategy;

  const AppImage({
    super.key,
    required this.imageUrl,
    required this.strategy,
    this.blurHash,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.onImageLoaded,
  });

  @override
  Widget build(BuildContext context) {
    return Image(
      image: StrategyImageProvider(
        url: imageUrl,
        strategy: strategy,
        onImageLoaded: onImageLoaded,
      ),
      width: width,
      height: height,
      fit: fit,
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        return _AppImagePresenter(
          frame: frame,
          wasSynchronouslyLoaded: wasSynchronouslyLoaded,
          blurHash: blurHash,
          width: width,
          height: height,
          placeholder: placeholder,
          child: child,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _AppImageErrorPresenter(
          blurHash: blurHash,
          width: width,
          height: height,
          placeholder: placeholder,
          errorWidget: errorWidget,
        );
      },
    );
  }
}

class _AppImagePresenter extends StatelessWidget {
  final int? frame;
  final bool wasSynchronouslyLoaded;
  final String? blurHash;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget child;

  const _AppImagePresenter({
    required this.frame,
    required this.wasSynchronouslyLoaded,
    required this.blurHash,
    required this.width,
    required this.height,
    required this.placeholder,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (wasSynchronouslyLoaded) return child;

    if (blurHash == null) {
      if (frame == null) {
        return AppImagePlaceholder(
          blurHash: blurHash,
          width: width,
          height: height,
          placeholder: placeholder,
        );
      }
      return child;
    }

    return Stack(
      fit: StackFit.passthrough,
      alignment: Alignment.center,
      children: [
        AnimatedOpacity(
          opacity: frame == null ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 600),
          curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
          child: AppImagePlaceholder(
            blurHash: blurHash,
            width: width,
            height: height,
            placeholder: placeholder,
          ),
        ),
        AnimatedOpacity(
          opacity: frame == null ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 600),
          curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
          child: child,
        ),
      ],
    );
  }
}

class _AppImageErrorPresenter extends StatelessWidget {
  final String? blurHash;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;

  const _AppImageErrorPresenter({
    required this.blurHash,
    required this.width,
    required this.height,
    required this.placeholder,
    required this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (blurHash != null && errorWidget == null) {
      return AppImagePlaceholder(
        blurHash: blurHash,
        width: width,
        height: height,
        placeholder: placeholder,
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: Center(
        child:
            errorWidget ??
            placeholder ??
            const Icon(Icons.broken_image, size: 24.0),
      ),
    );
  }
}
