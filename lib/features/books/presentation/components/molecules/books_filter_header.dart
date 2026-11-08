import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

import '../../../../../shared/components/atoms/app_sheet_title.dart';

class BooksFilterHeader extends StatelessWidget {
  final VoidCallback onClear;

  const BooksFilterHeader({super.key, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppSheetTitle(text: l10n.booksFilterTitle),
        TextButton(onPressed: onClear, child: Text(l10n.booksClearFilters)),
      ],
    );
  }
}
