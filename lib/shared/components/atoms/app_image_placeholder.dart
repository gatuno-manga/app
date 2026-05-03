import 'package:blurhash_dart/blurhash_dart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import 'app_skeleton.dart';

class AppImagePlaceholder extends StatefulWidget {
  final String? blurHash;
  final double? width;
  final double? height;
  final Widget? placeholder;

  const AppImagePlaceholder({
    super.key,
    this.blurHash,
    this.width,
    this.height,
    this.placeholder,
  });

  @override
  State<AppImagePlaceholder> createState() => _AppImagePlaceholderState();
}

class _AppImagePlaceholderState extends State<AppImagePlaceholder> {
  Uint8List? _bytes;
  String? _lastHash;

  @override
  void initState() {
    super.initState();
    _decodeIfNecessary();
  }

  @override
  void didUpdateWidget(AppImagePlaceholder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.blurHash != oldWidget.blurHash) {
      _decodeIfNecessary();
    }
  }

  void _decodeIfNecessary() {
    if (widget.blurHash == null) {
      _bytes = null;
      _lastHash = null;
      return;
    }

    if (widget.blurHash == _lastHash) return;

    _lastHash = widget.blurHash;
    _decodeBlurHash(widget.blurHash!);
  }

  Future<void> _decodeBlurHash(String hash) async {
    try {
      // 32x32 BlurHash is fast enough to decode synchronously
      // but we still use Future to avoid blocking the current frame
      final bytes = _decode(hash);
      if (mounted && _lastHash == hash) {
        setState(() => _bytes = bytes);
      }
    } catch (e) {
      // If decoding fails, fallback to skeleton
      if (mounted && _lastHash == hash) {
        setState(() => _bytes = null);
      }
    }
  }

  static Uint8List _decode(String hash) {
    final blurHash = BlurHash.decode(hash);
    final image = blurHash.toImage(32, 32);
    return Uint8List.fromList(img.encodeJpg(image));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.blurHash != null) {
      if (_bytes != null) {
        return Image.memory(
          _bytes!,
          width: widget.width,
          height: widget.height,
          fit: BoxFit.fill,
          gaplessPlayback: true,
        );
      }

      // Show skeleton while decoding
      return AppSkeleton(width: widget.width, height: widget.height);
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: widget.placeholder ?? AppSkeleton(width: widget.width, height: widget.height),
    );
  }
}
