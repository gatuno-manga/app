import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

import '../../../domain/entities/books_view_preferences.dart';

/// Picks between page buttons and infinite scroll.
class BooksNavigationModePicker extends StatelessWidget {
  final BooksNavigationMode value;
  final ValueChanged<BooksNavigationMode> onChanged;

  const BooksNavigationModePicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(l10n.booksViewNavigation, style: theme.textTheme.labelLarge),
        SegmentedButton<BooksNavigationMode>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: BooksNavigationMode.pages,
              label: Text(l10n.booksViewNavigationPages),
            ),
            ButtonSegment(
              value: BooksNavigationMode.infinite,
              label: Text(l10n.booksViewNavigationInfinite),
            ),
          ],
          selected: {value},
          onSelectionChanged: (s) => onChanged(s.first),
        ),
      ],
    );
  }
}
