import 'package:flutter/material.dart';

import '../../../../../core/theme/app_palette.dart';

/// Miniature of a theme: background with two text bars and three accent dots.
class PalettePreview extends StatelessWidget {
  const PalettePreview({super.key, required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: palette.appBackground,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _bar(palette.text, 0.8),
            const SizedBox(height: 4),
            _bar(palette.textSecondary, 0.55),
            const SizedBox(height: 6),
            Wrap(
              spacing: 3,
              children: [
                _dot(palette.primary),
                _dot(palette.lilac),
                _dot(palette.cyan),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _bar(Color color, double widthFactor) => FractionallySizedBox(
    widthFactor: widthFactor,
    child: Container(
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(2)),
      ),
    ),
  );

  static Widget _dot(Color color) => Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
