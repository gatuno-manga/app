import 'package:flutter/material.dart';

import '../../../domain/entities/book.dart';
import '../../../domain/entities/books_view_preferences.dart';
import '../molecules/book_card.dart';
import '../molecules/book_cover_card.dart';
import 'book_grid.dart';
import 'book_list.dart';

/// The scrollable book list in whichever layout the preferences ask for.
class BooksCollection extends StatelessWidget {
  final List<Book> books;
  final BooksViewPreferences preferences;
  final Widget? footer;
  final ScrollController? scrollController;

  const BooksCollection({
    super.key,
    required this.books,
    required this.preferences,
    this.footer,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return switch (preferences.layout) {
      BooksLayoutMode.grid => BookGrid(
        books: books,
        columns: preferences.columns,
        childAspectRatio: BookCard.aspectRatio,
        itemBuilder: (book) => BookCard(book: book),
        footer: footer,
        scrollController: scrollController,
      ),
      BooksLayoutMode.cover => BookGrid(
        books: books,
        columns: preferences.columns,
        childAspectRatio: BookCoverCard.aspectRatio,
        itemBuilder: (book) => BookCoverCard(book: book),
        footer: footer,
        scrollController: scrollController,
      ),
      BooksLayoutMode.list => BookListView(
        books: books,
        footer: footer,
        scrollController: scrollController,
      ),
    };
  }
}
