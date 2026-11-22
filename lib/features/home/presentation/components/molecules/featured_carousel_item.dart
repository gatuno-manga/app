import 'package:flutter/material.dart';
import '../../../../books/domain/entities/book.dart';
import '../atoms/featured_carousel_background.dart';
import '../atoms/featured_carousel_content.dart';
import '../../../../../core/router/shell_navigation.dart';

class FeaturedCarouselItem extends StatelessWidget {
  final Book book;

  const FeaturedCarouselItem({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushInTab('/books/${book.id}'),
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
