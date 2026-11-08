import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

import '../../../../../shared/components/molecules/app_icon_segmented_control.dart';
import '../../../domain/entities/books_view_preferences.dart';

/// Figma `Seletor cíclico/Visualização`: grid, list, covers.
class BooksViewModeSelector extends StatelessWidget {
  final BooksLayoutMode value;
  final ValueChanged<BooksLayoutMode> onChanged;

  const BooksViewModeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppIconSegmentedControl<BooksLayoutMode>(
      options: [
        AppIconSegmentOption(
          value: BooksLayoutMode.grid,
          icon: Icons.grid_view,
          label: l10n.booksViewGrid,
        ),
        AppIconSegmentOption(
          value: BooksLayoutMode.list,
          icon: Icons.view_list,
          label: l10n.booksViewList,
        ),
        AppIconSegmentOption(
          value: BooksLayoutMode.cover,
          icon: Icons.image,
          label: l10n.booksViewCover,
        ),
      ],
      value: value,
      onChanged: onChanged,
    );
  }
}
