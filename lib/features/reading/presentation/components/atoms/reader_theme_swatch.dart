import 'package:flutter/material.dart';

import '../../../../../core/theme/reader_palette.dart';

/// One reader theme option (Figma `Leitor/Tema de leitura`): an "Aa" sample
/// painted in the palette, with its label below.
class ReaderThemeSwatch extends StatelessWidget {
  final ReaderPalette palette;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ReaderThemeSwatch({
    super.key,
    required this.palette,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  /// `radius/md`
  static const BorderRadius _radius = BorderRadius.all(Radius.circular(8));

  /// Same as `ReaderThemeScope`, so the ring and the sheet change together.
  static const Duration _duration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : _duration;
    return Semantics(
      button: true,
      selected: isSelected,
      inMutuallyExclusiveGroup: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: _radius,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              key: const ValueKey('reader-theme-swatch-sample'),
              duration: duration,
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: palette.background,
                borderRadius: _radius,
                // Constant width: selection must not shift the layout.
                border: Border.all(
                  color: isSelected ? scheme.primary : palette.border,
                  width: 2,
                ),
              ),
              child: SizedBox(
                height: 56,
                child: Center(
                  child: Text(
                    'Aa',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: palette.text,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Weight carries the selected state (Figma): `color/primary`
            // fails contrast for 12 dp text in the Light and Dracula themes.
            AnimatedDefaultTextStyle(
              duration: duration,
              curve: Curves.easeOut,
              style: theme.textTheme.labelSmall!.copyWith(
                color: scheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
