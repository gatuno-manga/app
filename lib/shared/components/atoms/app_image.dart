import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/image/image_loading_strategy.dart';
import 'app_image_placeholder.dart';

class AppImage extends StatefulWidget {
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
  State<AppImage> createState() => _AppImageState();
}

class _AppImageState extends State<AppImage> {
  late Future<Uint8List?> _fetchFuture;

  @override
  void initState() {
    super.initState();
    _fetchFuture = _fetchImage();
  }

  @override
  void didUpdateWidget(AppImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.strategy != widget.strategy) {
      setState(() {
        _fetchFuture = _fetchImage();
      });
    }
  }

  Future<Uint8List?> _fetchImage() {
    return widget.strategy.loadImage(
      widget.imageUrl,
      onImageLoaded: widget.onImageLoaded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _fetchFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return AppImagePlaceholder(
            key: const ValueKey('waiting'),
            blurHash: widget.blurHash,
            width: widget.width,
            height: widget.height,
            placeholder: widget.placeholder,
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          if (widget.blurHash != null && widget.errorWidget == null) {
            return AppImagePlaceholder(
              key: const ValueKey('error'),
              blurHash: widget.blurHash,
              width: widget.width,
              height: widget.height,
              placeholder: widget.placeholder,
            );
          }

          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: Center(
              child:
                  widget.errorWidget ??
                  widget.placeholder ??
                  const Icon(Icons.broken_image, size: 24.0),
            ),
          );
        }

        return Image.memory(
          snapshot.data!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          gaplessPlayback: true,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;

            return Stack(
              fit: StackFit.passthrough,
              alignment: Alignment.center,
              children: [
                AnimatedOpacity(
                  opacity: frame == null ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 600),
                  curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                  child: AppImagePlaceholder(
                    key: const ValueKey('placeholder'),
                    blurHash: widget.blurHash,
                    width: widget.width,
                    height: widget.height,
                    placeholder: widget.placeholder,
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
          },
          errorBuilder: (context, error, stackTrace) {
            return AppImagePlaceholder(
              key: const ValueKey('error'),
              blurHash: widget.blurHash,
              width: widget.width,
              height: widget.height,
              placeholder: widget.placeholder,
            );
          },
        );
      },
    );
  }
}
