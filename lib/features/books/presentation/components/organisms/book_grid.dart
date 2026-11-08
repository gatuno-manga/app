import 'package:flutter/material.dart';
import '../../../domain/entities/book.dart';

class BookGrid extends StatelessWidget {
  final List<Book> books;
  final int columns;
  final double childAspectRatio;
  final Widget Function(Book book) itemBuilder;
  final Widget? footer;

  const BookGrid({
    super.key,
    required this.books,
    required this.columns,
    required this.childAspectRatio,
    required this.itemBuilder,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          // Same side inset as the toolbar and the list rows.
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              childAspectRatio: childAspectRatio,
              // Figma gutters: 16 between columns, 20 between rows.
              crossAxisSpacing: 16,
              mainAxisSpacing: 20,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => itemBuilder(books[index]),
              childCount: books.length,
            ),
          ),
        ),
        if (footer != null) SliverToBoxAdapter(child: footer),
      ],
    );
  }
}
