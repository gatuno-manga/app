import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/reader_preferences.dart';
import '../../../domain/use_cases/reader_preferences_service.dart';
import '../molecules/reader_alignment_row.dart';
import '../molecules/reader_font_family_row.dart';
import '../molecules/reader_navigation_row.dart';
import '../molecules/reader_stepper_row.dart';
import 'reader_accessibility_sheet.dart';
import 'reader_preferences_controls.dart';

/// The text reader's rows of the settings sheet (Figma tab `Texto`): font
/// family, font size, line spacing and alignment, then a row that opens the
/// accessibility sheet. Changes are functions of
/// the current value, so rapid changes compose instead of overwriting.
class TextReaderSettingsSection extends StatelessWidget {
  final TextReaderPreferences preferences;
  final ValueChanged<TextReaderPreferencesChange> onChanged;

  const TextReaderSettingsSection({
    super.key,
    required this.preferences,
    required this.onChanged,
  });

  /// This section as a reader's [ReaderSettingsSections]; independent of the
  /// value being read, so it can be built once.
  static ReaderSettingsSections sectionsFor(ReaderPreferencesService service) =>
      (preferences) => [
        TextReaderSettingsSection(
          preferences: preferences.text,
          onChanged: (change) => service.update(
            (current) => current.copyWith(text: change(current.text)),
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        ReaderFontFamilyRow(
          value: preferences.fontFamily,
          onChanged: (family) =>
              onChanged((t) => t.copyWith(fontFamily: family)),
        ),
        ReaderStepperRow(
          icon: Icons.format_size,
          title: l10n.readingFontSize(preferences.fontSize.round()),
          subtitle: l10n.readingFontSizeDesc,
          onDecrement: preferences.canDecreaseFontSize
              ? () => onChanged((t) => t.stepFontSize(-1))
              : null,
          onIncrement: preferences.canIncreaseFontSize
              ? () => onChanged((t) => t.stepFontSize(1))
              : null,
          decrementTooltip: l10n.readingDecreaseFontSize,
          incrementTooltip: l10n.readingIncreaseFontSize,
        ),
        ReaderStepperRow(
          icon: Icons.format_line_spacing,
          title: l10n.readingLineHeight(preferences.lineHeight),
          subtitle: l10n.readingLineHeightDesc,
          onDecrement: preferences.canDecreaseLineHeight
              ? () => onChanged((t) => t.stepLineHeight(-1))
              : null,
          onIncrement: preferences.canIncreaseLineHeight
              ? () => onChanged((t) => t.stepLineHeight(1))
              : null,
          decrementTooltip: l10n.readingDecreaseLineHeight,
          incrementTooltip: l10n.readingIncreaseLineHeight,
        ),
        ReaderAlignmentRow(
          value: preferences.alignment,
          onChanged: (alignment) =>
              onChanged((t) => t.copyWith(alignment: alignment)),
        ),
        ReaderNavigationRow(
          icon: Icons.accessibility_new,
          title: l10n.readingAccessibilityTitle,
          subtitle: l10n.readingAccessibilityDesc,
          onTap: () => ReaderAccessibilitySheet.show(context),
        ),
      ],
    );
  }
}
