import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

import '../../../../../shared/components/molecules/app_labeled_segmented_button.dart';
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

    return AppLabeledSegmentedButton<BooksNavigationMode>(
      label: l10n.booksViewNavigation,
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
      value: value,
      onChanged: onChanged,
    );
  }
}
