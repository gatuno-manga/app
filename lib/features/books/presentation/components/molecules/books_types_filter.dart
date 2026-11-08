import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

import '../../../domain/entities/book_type.dart';
import '../../book_type_label.dart';

class BooksTypesFilter extends StatelessWidget {
  final List<TypeBook>? selectedTypes;
  final void Function(TypeBook, bool) onSelected;

  const BooksTypesFilter({
    super.key,
    required this.selectedTypes,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.booksTypes, style: theme.textTheme.titleMedium),
        Wrap(
          spacing: 8,
          children: TypeBook.values.map((type) {
            final isSelected = selectedTypes?.contains(type) ?? false;
            return FilterChip(
              label: Text(bookTypeLabel(l10n, type)),
              selected: isSelected,
              onSelected: (selected) => onSelected(type, selected),
            );
          }).toList(),
        ),
      ],
    );
  }
}
