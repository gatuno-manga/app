import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/reader_preferences.dart';
import 'reader_choice_row.dart';

/// The paragraph alignment choice (Figma `Alinhamento`), shared by the text
/// and the accessibility sheets.
class ReaderAlignmentRow extends StatelessWidget {
  final ReaderTextAlignment value;
  final ValueChanged<ReaderTextAlignment> onChanged;

  const ReaderAlignmentRow({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static String labelOf(AppLocalizations l10n, ReaderTextAlignment value) =>
      switch (value) {
        ReaderTextAlignment.left => l10n.readingAlignLeft,
        ReaderTextAlignment.center => l10n.readingAlignCenter,
        ReaderTextAlignment.justify => l10n.readingAlignJustify,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ReaderChoiceRow<ReaderTextAlignment>(
      icon: Icons.format_align_left,
      title: l10n.readingAlignment,
      subtitle: l10n.readingAlignmentDesc,
      value: value,
      options: [
        for (final alignment in ReaderTextAlignment.values)
          ReaderChoice(alignment, labelOf(l10n, alignment)),
      ],
      onChanged: onChanged,
    );
  }
}
