import 'package:flutter/material.dart';
import '../../../domain/entities/book.dart';
import '../molecules/book_list_item.dart';

class BookListView extends StatelessWidget {
  final List<Book> books;
  final Widget? footer;

  const BookListView({super.key, required this.books, this.footer});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
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
