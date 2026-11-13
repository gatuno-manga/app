import 'package:flutter/material.dart';

import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/reader_preferences.dart';
import '../atoms/reader_summary_chip.dart';
import '../atoms/reader_switch.dart';
import 'reader_alignment_row.dart';
import 'reader_font_family_row.dart';
import 'reader_theme_picker.dart';

/// The dyslexia preset (Figma `Leitor/Predefinição · Modo dislexia`): a
/// switch and a chip per setting it controls, showing the current values
/// (they follow the user's edits while the preset is on).
class ReaderDyslexiaPresetCard extends StatelessWidget {
  final ReaderPreferences preferences;
  final ValueChanged<bool> onChanged;

  const ReaderDyslexiaPresetCard({
    super.key,
    required this.preferences,
    required this.onChanged,
  });

  static String _percent(double em) => (em * 100).round().toString();

  List<String> _chips(AppLocalizations l10n) {
    final text = preferences.text;
    final lineWidth = text.lineWidth;
    return [
      l10n.readingChipFont(ReaderFontFamilyRow.labelOf(l10n, text.fontFamily)),
      l10n.readingChipAlignment(
        ReaderAlignmentRow.labelOf(l10n, text.alignment),
      ),
      if (text.letterSpacing > 0)
        l10n.readingChipLetters(_percent(text.letterSpacing)),
      if (text.wordSpacing > 0)
        l10n.readingChipWords(_percent(text.wordSpacing)),
      l10n.readingChipLine(text.lineHeight),
      if (lineWidth != null) l10n.readingChipWidth(lineWidth.round()),
      l10n.readingChipBackground(
        ReaderThemePicker.labelOf(l10n, preferences.theme),
      ),
      if (text.suppressItalics) l10n.readingChipNoItalics,
      if (text.readingRuler) l10n.readingChipRuler,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.1),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.15)),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  child: SizedBox.square(
                    dimension: 40,
                    child: Center(
                      child: ExcludeSemantics(
                        child: Text(
                          'Aa',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: scheme.onPrimary,
                            fontFamily: AppTypography.lexend,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.readingDyslexiaTitle,
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        l10n.readingDyslexiaDesc,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ReaderSwitch(
                  value: preferences.dyslexiaMode,
                  onChanged: onChanged,
                  label: l10n.readingDyslexiaTitle,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final chip in _chips(l10n)) ReaderSummaryChip(label: chip),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
