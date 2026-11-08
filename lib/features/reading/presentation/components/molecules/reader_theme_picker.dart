import 'package:flutter/material.dart';

import '../../../../../core/theme/theme.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/reader_preferences.dart';
import '../../theme/reader_theme_palette.dart';
import '../atoms/reader_theme_swatch.dart';

/// Row of one [ReaderThemeSwatch] per [ReaderTheme].
class ReaderThemePicker extends StatelessWidget {
  final ReaderTheme selected;
  final ValueChanged<ReaderTheme> onSelected;

  const ReaderThemePicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static String _labelOf(AppLocalizations l10n, ReaderTheme theme) =>
      switch (theme) {
        ReaderTheme.standard => l10n.readingThemeStandard,
        ReaderTheme.sepia => l10n.readingThemeSepia,
        ReaderTheme.cream => l10n.readingThemeCream,
        ReaderTheme.highContrast => l10n.readingThemeHighContrast,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final app = Theme.of(context).extension<GatunoColors>()!.palette;
    return Semantics(
      container: true,
      label: l10n.readingThemeTitle,
      child: Row(
        // Labels may wrap to two lines; the samples stay on one baseline.
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final theme in ReaderTheme.values) ...[
            if (theme != ReaderTheme.values.first) const SizedBox(width: 8),
            Expanded(
              child: ReaderThemeSwatch(
                palette: theme.palette(app),
                label: _labelOf(l10n, theme),
                isSelected: theme == selected,
                onTap: () => onSelected(theme),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
