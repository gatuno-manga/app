import 'package:flutter/material.dart';

import '../../../../../core/theme/reader_palette.dart';
import '../../theme/reader_theme_scope.dart';

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

  static const double _dotSize = 4;
  static const double _dotGap = 6;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final duration = ReaderThemeScope.durationOf(context);
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
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Aa',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: palette.text,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // The label keeps `color/text` (`onSurface`) in both states:
            // `color/primary` on the sheet is 3.5-3.7:1 in some app themes
            // (issue #114). Selection shows as weight plus the primary dot.
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
            const SizedBox(height: _dotGap),
            // Always laid out so selecting does not shift the row; only the
            // fill changes. Non-text, so `color/primary` needs 3:1.
            AnimatedContainer(
              key: const ValueKey('reader-theme-swatch-dot'),
              duration: duration,
              curve: Curves.easeOut,
              width: _dotSize,
              height: _dotSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? scheme.primary : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
