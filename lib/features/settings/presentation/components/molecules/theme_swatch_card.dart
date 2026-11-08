import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_choice.dart';
import '../atoms/selected_check_badge.dart';
import 'theme_preview.dart';

/// One selectable theme card: preview, label and selected state.
class ThemeSwatchCard extends StatelessWidget {
  const ThemeSwatchCard({
    super.key,
    required this.choice,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final AppThemeChoice choice;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static const double _width = 104;
  static const BorderRadius _radius = BorderRadius.all(Radius.circular(12));
  static const BorderRadius _innerRadius = BorderRadius.all(Radius.circular(8));

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: isSelected,
      inMutuallyExclusiveGroup: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: SizedBox(
        width: _width,
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: _radius,
                // Constant width: selection must not shift the layout.
                border: Border.all(
                  color: isSelected ? scheme.primary : scheme.outlineVariant,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: _innerRadius,
                        child: ThemePreview(choice: choice),
                      ),
                      if (isSelected)
                        const Positioned(
                          top: 4,
                          right: 4,
                          child: SelectedCheckBadge(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
            // Above the preview so hover, focus and press feedback is visible.
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  key: ValueKey('theme-swatch-${choice.name}'),
                  onTap: onTap,
                  borderRadius: _radius,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
