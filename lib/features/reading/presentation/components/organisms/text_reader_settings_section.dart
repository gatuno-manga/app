import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/reader_preferences.dart';
import '../molecules/reader_choice_row.dart';
import '../molecules/reader_stepper_row.dart';

/// Applies a change to the current [ReaderPreferences]; sections never see
/// a stale value, so rapid changes compose instead of overwriting.
typedef ReaderPreferencesChange =
    ReaderPreferences Function(ReaderPreferences current);

/// The text reader's rows of the settings sheet (Figma tab `Texto`): font
/// family, font size, line spacing and alignment.
class TextReaderSettingsSection extends StatelessWidget {
  final ReaderPreferences preferences;
  final ValueChanged<ReaderPreferencesChange> onChanged;

  const TextReaderSettingsSection({
    super.key,
    required this.preferences,
    required this.onChanged,
  });

  void _changeText(
    TextReaderPreferences Function(TextReaderPreferences text) change,
  ) => onChanged((current) => current.copyWith(text: change(current.text)));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = preferences.text;
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
              _changeText((t) => t.copyWith(fontFamily: family)),
        ),
        ReaderStepperRow(
          icon: Icons.format_size,
          title: l10n.readingFontSize(text.fontSize.round()),
          subtitle: l10n.readingFontSizeDesc,
          onDecrement: text.canDecreaseFontSize
              ? () => _changeText((t) => t.stepFontSize(-1))
              : null,
          onIncrement: text.canIncreaseFontSize
              ? () => _changeText((t) => t.stepFontSize(1))
              : null,
          decrementTooltip: l10n.readingDecreaseFontSize,
          incrementTooltip: l10n.readingIncreaseFontSize,
        ),
        ReaderStepperRow(
          icon: Icons.format_line_spacing,
          title: l10n.readingLineHeight(text.lineHeight),
          subtitle: l10n.readingLineHeightDesc,
          onDecrement: text.canDecreaseLineHeight
              ? () => _changeText((t) => t.stepLineHeight(-1))
              : null,
          onIncrement: text.canIncreaseLineHeight
              ? () => _changeText((t) => t.stepLineHeight(1))
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
              _changeText((t) => t.copyWith(alignment: alignment)),
        ),
      ],
    );
  }
}
