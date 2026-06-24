import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../books/domain/entities/book.dart';
import '../atoms/featured_carousel_background.dart';
import '../atoms/featured_carousel_content.dart';

class FeaturedCarouselItem extends StatelessWidget {
  final Book book;

  const FeaturedCarouselItem({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/books/${book.id}'),
      child: Stack(
        fit: StackFit.expand,
        children: [
          FeaturedCarouselBackground(book: book),
          FeaturedCarouselContent(book: book),
        ],
      ),
    );
  }
}
