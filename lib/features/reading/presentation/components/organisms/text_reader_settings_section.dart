import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/reader_preferences.dart';
import '../molecules/reader_choice_row.dart';
import '../molecules/reader_stepper_row.dart';

/// The text reader's rows of the settings sheet (Figma tab `Texto`): font
/// family, font size, line spacing and alignment. Changes are functions of
/// the current value, so rapid changes compose instead of overwriting.
class TextReaderSettingsSection extends StatelessWidget {
  final TextReaderPreferences preferences;
  final ValueChanged<TextReaderPreferencesChange> onChanged;

  const TextReaderSettingsSection({
    super.key,
    required this.preferences,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = preferences;
    return Column(
      children: [
        ReaderChoiceRow<ReaderFontFamily>(
          icon: Icons.text_fields,
          title: l10n.readingFontFamily,
          subtitle: l10n.readingFontFamilyDesc,
          value: text.fontFamily,
          options: [
            ReaderChoice(ReaderFontFamily.serif, l10n.readingFontSerif),
            ReaderChoice(ReaderFontFamily.sans, l10n.readingFontSans),
            ReaderChoice(ReaderFontFamily.lexend, l10n.readingFontLexend),
            ReaderChoice(ReaderFontFamily.atkinson, l10n.readingFontAtkinson),
            ReaderChoice(
              ReaderFontFamily.openDyslexic,
              l10n.readingFontOpenDyslexic,
            ),
          ],
          onChanged: (family) =>
              onChanged((t) => t.copyWith(fontFamily: family)),
        ),
        ReaderStepperRow(
          icon: Icons.format_size,
          title: l10n.readingFontSize(text.fontSize.round()),
          subtitle: l10n.readingFontSizeDesc,
          onDecrement: text.canDecreaseFontSize
              ? () => onChanged((t) => t.stepFontSize(-1))
              : null,
          onIncrement: text.canIncreaseFontSize
              ? () => onChanged((t) => t.stepFontSize(1))
              : null,
          decrementTooltip: l10n.readingDecreaseFontSize,
          incrementTooltip: l10n.readingIncreaseFontSize,
        ),
        ReaderStepperRow(
          icon: Icons.format_line_spacing,
          title: l10n.readingLineHeight(text.lineHeight),
          subtitle: l10n.readingLineHeightDesc,
          onDecrement: text.canDecreaseLineHeight
              ? () => onChanged((t) => t.stepLineHeight(-1))
              : null,
          onIncrement: text.canIncreaseLineHeight
              ? () => onChanged((t) => t.stepLineHeight(1))
              : null,
          decrementTooltip: l10n.readingDecreaseLineHeight,
          incrementTooltip: l10n.readingIncreaseLineHeight,
        ),
        ReaderChoiceRow<ReaderTextAlignment>(
          icon: Icons.format_align_left,
          title: l10n.readingAlignment,
          subtitle: l10n.readingAlignmentDesc,
          value: text.alignment,
          options: [
            ReaderChoice(ReaderTextAlignment.left, l10n.readingAlignLeft),
            ReaderChoice(ReaderTextAlignment.center, l10n.readingAlignCenter),
            ReaderChoice(ReaderTextAlignment.justify, l10n.readingAlignJustify),
          ],
          onChanged: (alignment) =>
              onChanged((t) => t.copyWith(alignment: alignment)),
        ),
      ],
    );
  }
}
