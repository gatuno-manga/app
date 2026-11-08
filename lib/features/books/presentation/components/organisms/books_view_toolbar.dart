import 'package:flutter/material.dart';

import '../../../domain/entities/books_view_preferences.dart';
import '../atoms/books_view_options_action.dart';
import '../molecules/books_view_mode_selector.dart';

/// The Figma "controller" row above the list: view selector and options.
class BooksViewToolbar extends StatelessWidget {
  final BooksLayoutMode layout;
  final ValueChanged<BooksLayoutMode> onLayoutChanged;
  final VoidCallback onOptionsPressed;

  const BooksViewToolbar({
    super.key,
    required this.layout,
    required this.onLayoutChanged,
    required this.onOptionsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 8,
        children: [
          BooksViewModeSelector(value: layout, onChanged: onLayoutChanged),
          BooksViewOptionsAction(onPressed: onOptionsPressed),
        ],
      ),
    );
  }
}
