import 'package:flutter/material.dart';
import '../../../domain/entities/book.dart';
import '../molecules/book_list_item.dart';

class BookListView extends StatelessWidget {
  final List<Book> books;
  final Widget? footer;
  final ScrollController? scrollController;

  const BookListView({
    super.key,
    required this.books,
    this.footer,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFixedExtentList(
          itemExtent: 116.0,
          delegate: SliverChildBuilderDelegate(
            (context, index) => BookListItem(book: books[index]),
            childCount: books.length,
          ),
        ),
        if (footer != null) SliverToBoxAdapter(child: footer),
      ],
    );
  }
}
