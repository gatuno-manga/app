import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_theme_choice.dart';

/// Grid of theme cards; each previews its [AppPalette]. [AppThemeChoice.system]
/// is a split Light/Dark card.
class ThemeSwatchGrid extends StatelessWidget {
  const ThemeSwatchGrid({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final AppThemeChoice selected;
  final ValueChanged<AppThemeChoice> onSelected;

  static String labelOf(AppLocalizations l10n, AppThemeChoice choice) =>
      switch (choice) {
        AppThemeChoice.system => l10n.settingsThemeSystem,
        AppThemeChoice.light => l10n.settingsThemeLight,
        AppThemeChoice.dark => l10n.settingsThemeDark,
        AppThemeChoice.trueDark => l10n.settingsThemeTrueDark,
        AppThemeChoice.dracula => l10n.settingsThemeDracula,
        AppThemeChoice.slate => l10n.settingsThemeSlate,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsThemeTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final choice in AppThemeChoice.values)
              _ThemeSwatchCard(
                choice: choice,
                label: labelOf(l10n, choice),
                isSelected: choice == selected,
                onTap: () => onSelected(choice),
              ),
          ],
        ),
      ],
    );
  }
}

class _ThemeSwatchCard extends StatelessWidget {
  const _ThemeSwatchCard({
    required this.choice,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final AppThemeChoice choice;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static const double _width = 96;
  static const double _previewHeight = 64;
  static const BorderRadius _radius = BorderRadius.all(Radius.circular(12));

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = choice.palette;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: SizedBox(
        width: _width,
        child: InkWell(
          key: ValueKey('theme-swatch-${choice.name}'),
          onTap: onTap,
          borderRadius: _radius,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: _radius,
              border: Border.all(
                color: isSelected ? scheme.primary : scheme.outlineVariant,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  child: SizedBox(
                    height: _previewHeight,
                    child: palette != null
                        ? _PalettePreview(palette: palette)
                        : const Row(
                            children: [
                              Expanded(
                                child: _PalettePreview(palette: lightPalette),
                              ),
                              Expanded(
                                child: _PalettePreview(palette: darkPalette),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSelected) ...[
                      Icon(Icons.check, size: 14, color: scheme.primary),
                      const SizedBox(width: 2),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PalettePreview extends StatelessWidget {
  const _PalettePreview({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: palette.appBackground,
      child: Padding(
        padding: const EdgeInsets.all(8),
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
