import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme.dart';

/// Loading placeholder, Figma `App/Atom/Esqueleto` (`1048:1822`): a
/// `color/text-10` bar with `radius/sm`. It never shows content; a caller that
/// may have the real value renders it instead of the skeleton.
class AppSkeleton extends StatelessWidget {
  /// A block of the given size, such as a cover or a card.
  const AppSkeleton.block({super.key, this.width, this.height})
    : _verticalMargin = 0;

  /// One line of text. Figma sizes it 160x16 and the instance overrides it.
  const AppSkeleton.textLine({super.key, this.width = 160, this.height = 16})
    : _verticalMargin = 4;

  final double? width;
  final double? height;
  final double _verticalMargin;

  @override
  Widget build(BuildContext context) {
    final palette =
        Theme.of(context).extension<GatunoColors>()?.palette ?? lightPalette;
    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.symmetric(vertical: _verticalMargin),
      decoration: BoxDecoration(
        color: palette.text10,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
