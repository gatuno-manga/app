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

  static const BorderRadius _radius = BorderRadius.all(Radius.circular(12));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
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
            DecoratedBox(
              key: const ValueKey('reader-theme-swatch-sample'),
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
            Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected ? scheme.primary : scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
