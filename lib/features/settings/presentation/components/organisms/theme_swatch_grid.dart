import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

import '../../../../../core/theme/app_theme_choice.dart';
import '../molecules/theme_swatch_card.dart';

/// Titled grid of [ThemeSwatchCard]s, one per [AppThemeChoice].
class ThemeSwatchGrid extends StatelessWidget {
  const ThemeSwatchGrid({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final AppThemeChoice selected;
  final ValueChanged<AppThemeChoice> onSelected;

  static String _labelOf(AppLocalizations l10n, AppThemeChoice choice) =>
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
    return Semantics(
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.settingsThemeTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final choice in AppThemeChoice.values)
                ThemeSwatchCard(
                  choice: choice,
                  label: _labelOf(l10n, choice),
                  isSelected: choice == selected,
                  onTap: () => onSelected(choice),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
