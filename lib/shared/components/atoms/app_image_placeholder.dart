import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';

import 'app_skeleton.dart';

class AppImagePlaceholder extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (blurHash != null) {
      final blurHashWidget = BlurHash(hash: blurHash!, imageFit: BoxFit.fill);

      if (width != null || height != null) {
        return SizedBox(width: width, height: height, child: blurHashWidget);
      }

      return blurHashWidget;
    }

    return SizedBox(
      width: width,
      height: height,
      child: placeholder ?? AppSkeleton(width: width, height: height),
    );
  }
}
