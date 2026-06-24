import 'package:flutter/material.dart';
import '../../../../books/domain/entities/book.dart';
import '../../../../books/presentation/components/molecules/book_card.dart';
import '../../../../../shared/components/atoms/app_skeleton.dart';

class HorizontalBookList extends StatelessWidget {
  final List<Book> books;
  final bool isLoading;
  final double cardWidth;
  final double cardHeight;

  const HorizontalBookList({
    super.key,
    required this.books,
    this.isLoading = false,
    this.cardWidth = 140,
    this.cardHeight = 210,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: cardHeight,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            return AppSkeleton(
              width: cardWidth,
              height: cardHeight,
              borderRadius: BorderRadius.circular(8),
            );
          },
        ),
      );
    }

    if (books.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final book = books[index];
          return SizedBox(
            width: cardWidth,
            child: BookCard(book: book),
          );
        },
      ),
    );
  }
}
