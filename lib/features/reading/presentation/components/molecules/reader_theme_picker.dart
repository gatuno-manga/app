import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/reader_preferences.dart';
import '../../theme/reader_theme_palette.dart';
import '../atoms/reader_theme_swatch.dart';

/// One [ReaderThemeSwatch] per [ReaderTheme], four in a row; two rows of two
/// when the widest label would not fit a quarter of the width (large text
/// scales), so labels never break mid-word.
class ReaderThemePicker extends StatelessWidget {
  final ReaderTheme selected;
  final ValueChanged<ReaderTheme> onSelected;

  const ReaderThemePicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const double _gap = 8;

  /// Label of [theme] in the reader theme picker and the preset summary.
  static String labelOf(AppLocalizations l10n, ReaderTheme theme) =>
      switch (theme) {
        ReaderTheme.standard => l10n.readingThemeStandard,
        ReaderTheme.sepia => l10n.readingThemeSepia,
        ReaderTheme.cream => l10n.readingThemeCream,
        ReaderTheme.highContrast => l10n.readingThemeHighContrast,
      };

  /// Width of the widest label as it will render, including the selected
  /// weight, so the layout does not change when the selection does.
  static double _widestLabel(BuildContext context, Iterable<String> labels) {
    final style = Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600);
    final scaler = MediaQuery.textScalerOf(context);
    var widest = 0.0;
    for (final label in labels) {
      final painter = TextPainter(
        text: TextSpan(text: label, style: style),
        textDirection: Directionality.of(context),
        textScaler: scaler,
      )..layout();
      widest = widest > painter.width ? widest : painter.width;
      painter.dispose();
    }
    return widest;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themes = ReaderTheme.values;
    final labels = {for (final t in themes) t: labelOf(l10n, t)};
    return Semantics(
      container: true,
      label: l10n.readingThemeTitle,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final quarter = (constraints.maxWidth - 3 * _gap) / themes.length;
          final columns = _widestLabel(context, labels.values) > quarter
              ? 2
              : themes.length;
          final width = (constraints.maxWidth - (columns - 1) * _gap) / columns;
          return Wrap(
            spacing: _gap,
            runSpacing: _gap,
            children: [
              for (final theme in themes)
                SizedBox(
                  width: width,
                  child: ReaderThemeSwatch(
                    palette: theme.paletteOf(context),
                    label: labels[theme]!,
                    isSelected: theme == selected,
                    onTap: () => onSelected(theme),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
