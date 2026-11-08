import 'package:flutter/material.dart';
import '../../../domain/entities/book.dart';

class BookGrid extends StatelessWidget {
  final List<Book> books;
  final int columns;
  final double childAspectRatio;
  final Widget Function(Book book) itemBuilder;
  final Widget? footer;
  final ScrollController? scrollController;

  const BookGrid({
    super.key,
    required this.books,
    required this.columns,
    required this.childAspectRatio,
    required this.itemBuilder,
    this.footer,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(8),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
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
