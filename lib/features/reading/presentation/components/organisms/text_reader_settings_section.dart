import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/components/molecules/app_stepper.dart';
import '../../../domain/entities/reader_preferences.dart';
import '../molecules/reader_choice_row.dart';
import '../molecules/reader_setting_row.dart';

/// The text reader's rows of the settings sheet (Figma tab `Texto`): font
/// family, font size, line spacing and alignment.
class TextReaderSettingsSection extends StatelessWidget {
  final ReaderPreferences preferences;
  final ValueChanged<ReaderPreferences> onChanged;

  const TextReaderSettingsSection({
    super.key,
    required this.preferences,
    required this.onChanged,
  });

  TextReaderPreferences get _text => preferences.text;

  void _emit(TextReaderPreferences text) =>
      onChanged(preferences.copyWith(text: text));

  /// Keeps one decimal so `1.8 + 0.1` stores as `1.9`, not `1.9000000001`.
  static double _step(double value, double step) =>
      ((value + step) * 10).roundToDouble() / 10;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = _text;
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
          onChanged: (family) => _emit(text.copyWith(fontFamily: family)),
        ),
        ReaderSettingRow(
          icon: Icons.format_size,
          title: l10n.readingFontSize(text.fontSize.round()),
          subtitle: l10n.readingFontSizeDesc,
          trailing: AppStepper(
            onDecrement: text.fontSize > TextReaderPreferences.minFontSize
                ? () => _emit(
                    text.copyWith(
                      fontSize: _step(
                        text.fontSize,
                        -TextReaderPreferences.fontSizeStep,
                      ),
                    ),
                  )
                : null,
            onIncrement: text.fontSize < TextReaderPreferences.maxFontSize
                ? () => _emit(
                    text.copyWith(
                      fontSize: _step(
                        text.fontSize,
                        TextReaderPreferences.fontSizeStep,
                      ),
                    ),
                  )
                : null,
            decrementTooltip: l10n.readingDecrease,
            incrementTooltip: l10n.readingIncrease,
          ),
        ),
        ReaderSettingRow(
          icon: Icons.format_line_spacing,
          title: l10n.readingLineHeight(text.lineHeight.toStringAsFixed(1)),
          subtitle: l10n.readingLineHeightDesc,
          trailing: AppStepper(
            onDecrement: text.lineHeight > TextReaderPreferences.minLineHeight
                ? () => _emit(
                    text.copyWith(
                      lineHeight: _step(
                        text.lineHeight,
                        -TextReaderPreferences.lineHeightStep,
                      ),
                    ),
                  )
                : null,
            onIncrement: text.lineHeight < TextReaderPreferences.maxLineHeight
                ? () => _emit(
                    text.copyWith(
                      lineHeight: _step(
                        text.lineHeight,
                        TextReaderPreferences.lineHeightStep,
                      ),
                    ),
                  )
                : null,
            decrementTooltip: l10n.readingDecrease,
            incrementTooltip: l10n.readingIncrease,
          ),
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
          onChanged: (alignment) => _emit(text.copyWith(alignment: alignment)),
        ),
      ],
    );
  }
}
