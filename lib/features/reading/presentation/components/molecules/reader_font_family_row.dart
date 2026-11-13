import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/reader_preferences.dart';
import 'reader_choice_row.dart';

/// The font family choice (Figma `Fonte`), shared by the text and the
/// accessibility sheets.
class ReaderFontFamilyRow extends StatelessWidget {
  final ReaderFontFamily value;
  final ValueChanged<ReaderFontFamily> onChanged;

  const ReaderFontFamilyRow({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static String labelOf(AppLocalizations l10n, ReaderFontFamily family) =>
      switch (family) {
        ReaderFontFamily.serif => l10n.readingFontSerif,
        ReaderFontFamily.sans => l10n.readingFontSans,
        ReaderFontFamily.lexend => l10n.readingFontLexend,
        ReaderFontFamily.atkinson => l10n.readingFontAtkinson,
        ReaderFontFamily.openDyslexic => l10n.readingFontOpenDyslexic,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ReaderChoiceRow<ReaderFontFamily>(
      icon: Icons.text_fields,
      title: l10n.readingFontFamily,
      subtitle: l10n.readingFontFamilyDesc,
      value: value,
      options: [
        for (final family in ReaderFontFamily.values)
          ReaderChoice(family, labelOf(l10n, family)),
      ],
      onChanged: onChanged,
    );
  }
}
