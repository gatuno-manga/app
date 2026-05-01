import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import '../../../core/di/injection.dart';
import '../../../core/network/dio_client.dart';
import 'app_skeleton.dart';

class AppImage extends StatefulWidget {
  final String imageUrl;
  final String? blurHash;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final void Function(Size)? onImageLoaded;

  const AppImage({
    super.key,
    required this.imageUrl,
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
  final _dioClient = sl<DioClient>();

  @override
  void initState() {
    super.initState();
    _fetchFuture = _fetchImage();
  }

  @override
  void didUpdateWidget(AppImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      setState(() {
        _fetchFuture = _fetchImage();
      });
    }
  }

  Future<Uint8List?> _fetchImage() async {
    try {
      final response = await _dioClient.dio.get<List<int>>(
        widget.imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.data != null) {
        final bytes = Uint8List.fromList(response.data!);

        if (widget.onImageLoaded != null) {
          final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
          final descriptor = await ui.ImageDescriptor.encoded(buffer);
          widget.onImageLoaded!(
            Size(descriptor.width.toDouble(), descriptor.height.toDouble()),
          );
          descriptor.dispose();
          buffer.dispose();
        }

        return bytes;
      }
    } catch (e) {
      debugPrint('Error fetching image (${widget.imageUrl}): $e');
    }
    return null;
  }

  Widget _buildPlaceholder({Key? key}) {
    if (widget.blurHash != null) {
      final blurHashWidget = BlurHash(
        hash: widget.blurHash!,
        imageFit: BoxFit.fill,
      );

      if (widget.width != null || widget.height != null) {
        return SizedBox(
          key: key,
          width: widget.width,
          height: widget.height,
          child: blurHashWidget,
        );
      }

      return KeyedSubtree(key: key, child: blurHashWidget);
    }

    return SizedBox(
      key: key,
      width: widget.width,
      height: widget.height,
      child:
          widget.placeholder ??
          AppSkeleton(width: widget.width, height: widget.height),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _fetchFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildPlaceholder(key: const ValueKey('waiting'));
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          if (widget.blurHash != null && widget.errorWidget == null) {
            return _buildPlaceholder(key: const ValueKey('error'));
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
                  child: _buildPlaceholder(key: const ValueKey('placeholder')),
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
            return _buildPlaceholder(key: const ValueKey('error'));
          },
        );
      },
    );
  }
}
