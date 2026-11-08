import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

import '../../../domain/entities/books_view_preferences.dart';

/// Picks how many columns the grid and cover layouts use.
class BooksColumnsPicker extends StatelessWidget {
  final int value;

  /// Null disables the picker (the list layout has no columns).
  final ValueChanged<int>? onChanged;

  const BooksColumnsPicker({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(l10n.booksViewColumns, style: theme.textTheme.labelLarge),
        SegmentedButton<int>(
          showSelectedIcon: false,
          segments: [
            for (
              var n = BooksViewPreferences.minColumns;
              n <= BooksViewPreferences.maxColumns;
              n++
            )
              ButtonSegment(value: n, label: Text('$n')),
          ],
          selected: {value},
          onSelectionChanged: onChanged == null
              ? null
              : (s) => onChanged!(s.first),
        ),
      ],
    );
  }
}
