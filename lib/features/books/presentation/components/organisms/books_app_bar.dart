import 'package:flutter/material.dart';
import '../../../domain/entities/book_page_options.dart';
import '../atoms/books_filter_action.dart';
import '../molecules/books_search_field.dart';
import '../molecules/books_sort_action.dart';

class BooksAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final VoidCallback onFilterPressed;
  final void Function(String?) onSearchChanged;
  final void Function(String, SortOrder) onSortChanged;

  const BooksAppBar({
    super.key,
    required this.searchController,
    required this.onFilterPressed,
    required this.onSearchChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: BooksSearchField(
        controller: searchController,
        onChanged: onSearchChanged,
      ),
      actions: [
        BooksSortAction(onSortChanged: onSortChanged),
        BooksFilterAction(onPressed: onFilterPressed),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
