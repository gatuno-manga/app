import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_choice.dart';
import '../atoms/palette_preview.dart';

/// Preview of one [AppThemeChoice]. [AppThemeChoice.system] has no palette of
/// its own, so it shows the Light and Dark previews side by side.
class ThemePreview extends StatelessWidget {
  const ThemePreview({super.key, required this.choice});

  final AppThemeChoice choice;

  static const double height = 64;

  @override
  Widget build(BuildContext context) {
    final palette = choice.palette;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: palette != null
          ? PalettePreview(palette: palette)
          : Row(
              children: [
                Expanded(
                  child: PalettePreview(palette: AppThemeChoice.light.palette!),
                ),
                Expanded(
                  child: PalettePreview(palette: AppThemeChoice.dark.palette!),
                ),
              ],
            ),
    );
  }
}
