import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

import '../../../../../shared/components/molecules/app_labeled_segmented_button.dart';
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

    return AppLabeledSegmentedButton<int>(
      label: l10n.booksViewColumns,
      segments: [
        for (
          var n = BooksViewPreferences.minColumns;
          n <= BooksViewPreferences.maxColumns;
          n++
        )
          ButtonSegment(value: n, label: Text('$n')),
      ],
      value: value,
      onChanged: onChanged,
    );
  }
}
