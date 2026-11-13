import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/reader_preferences.dart';
import '../../../domain/use_cases/reader_preferences_service.dart';
import '../molecules/reader_alignment_row.dart';
import '../molecules/reader_dyslexia_preset_card.dart';
import '../molecules/reader_font_family_row.dart';
import '../molecules/reader_stepper_row.dart';
import '../molecules/reader_switch_row.dart';
import 'reader_preferences_controls.dart';

/// The rows of the accessibility sheet (Figma `Leitor · Ajustes ·
/// Acessibilidade`) after the theme picker: font, spacing, line width,
/// alignment, italics and the reading ruler.
class ReaderAccessibilitySection extends StatelessWidget {
  final TextReaderPreferences preferences;
  final ValueChanged<TextReaderPreferencesChange> onChanged;

  const ReaderAccessibilitySection({
    super.key,
    required this.preferences,
    required this.onChanged,
  });

  /// The preset card, shown before the theme picker.
  static ReaderSettingsSections leadingFor(ReaderPreferencesService service) =>
      (preferences) => [
        ReaderDyslexiaPresetCard(
          preferences: preferences,
          onChanged: (enabled) =>
              service.update((current) => current.withDyslexiaMode(enabled)),
        ),
        const SizedBox(height: 16),
      ];

  /// The rows below the theme picker.
  static ReaderSettingsSections sectionsFor(ReaderPreferencesService service) =>
      (preferences) => [
        ReaderAccessibilitySection(
          preferences: preferences.text,
          onChanged: (change) => service.update(
            (current) => current.copyWith(text: change(current.text)),
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lineWidth = preferences.lineWidth;
    return Column(
      children: [
        ReaderFontFamilyRow(
          value: preferences.fontFamily,
          onChanged: (family) =>
              onChanged((t) => t.copyWith(fontFamily: family)),
        ),
        ReaderStepperRow(
          icon: Icons.text_fields,
          title: l10n.readingLetterSpacing(
            (preferences.letterSpacing * 100).round(),
          ),
          subtitle: l10n.readingLetterSpacingDesc,
          onDecrement: preferences.canDecreaseLetterSpacing
              ? () => onChanged((t) => t.stepLetterSpacing(-1))
              : null,
          onIncrement: preferences.canIncreaseLetterSpacing
              ? () => onChanged((t) => t.stepLetterSpacing(1))
              : null,
          decrementTooltip: l10n.readingDecreaseLetterSpacing,
          incrementTooltip: l10n.readingIncreaseLetterSpacing,
        ),
        ReaderStepperRow(
          icon: Icons.space_bar,
          title: l10n.readingWordSpacing(
            (preferences.wordSpacing * 100).round(),
          ),
          subtitle: l10n.readingWordSpacingDesc,
          onDecrement: preferences.canDecreaseWordSpacing
              ? () => onChanged((t) => t.stepWordSpacing(-1))
              : null,
          onIncrement: preferences.canIncreaseWordSpacing
              ? () => onChanged((t) => t.stepWordSpacing(1))
              : null,
          decrementTooltip: l10n.readingDecreaseWordSpacing,
          incrementTooltip: l10n.readingIncreaseWordSpacing,
        ),
        ReaderStepperRow(
          icon: Icons.width_normal,
          title: lineWidth == null
              ? l10n.readingLineWidthOff
              : l10n.readingLineWidth(lineWidth.round()),
          subtitle: l10n.readingLineWidthDesc,
          onDecrement: preferences.canDecreaseLineWidth
              ? () => onChanged((t) => t.stepLineWidth(-1))
              : null,
          onIncrement: preferences.canIncreaseLineWidth
              ? () => onChanged((t) => t.stepLineWidth(1))
              : null,
          decrementTooltip: l10n.readingDecreaseLineWidth,
          incrementTooltip: l10n.readingIncreaseLineWidth,
        ),
        ReaderAlignmentRow(
          value: preferences.alignment,
          onChanged: (alignment) =>
              onChanged((t) => t.copyWith(alignment: alignment)),
        ),
        ReaderSwitchRow(
          icon: Icons.format_italic,
          title: l10n.readingSuppressItalics,
          subtitle: l10n.readingSuppressItalicsDesc,
          value: preferences.suppressItalics,
          onChanged: (value) =>
              onChanged((t) => t.copyWith(suppressItalics: value)),
        ),
        ReaderSwitchRow(
          icon: Icons.layers_outlined,
          title: l10n.readingRulerTitle,
          subtitle: l10n.readingRulerDesc,
          value: preferences.readingRuler,
          onChanged: (value) =>
              onChanged((t) => t.copyWith(readingRuler: value)),
        ),
      ],
    );
  }
}
