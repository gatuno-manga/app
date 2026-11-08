import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/book.dart';
import '../atoms/book_cover.dart';
import '../atoms/book_title_scrim.dart';
import '../atoms/book_type_badge.dart';

/// Cover-only card: the title sits over the art (Figma `/books — capa`).
class BookCoverCard extends StatelessWidget {
  final Book book;

  const BookCoverCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/books/${book.id}'),
        child: Stack(
          fit: StackFit.expand,
          children: [
            BookCover(
              imageUrl: book.cover?.value,
              blurHash: book.metadata?.blurHash,
              borderRadius: 0,
              iconSize: 60,
              usePlaceholderIfNull: true,
            ),
            PositionedBookTypeBadge(type: book.type, inset: 8),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BookTitleScrim(title: book.title.value),
            ),
          ],
        ),
      ),
    );
  }
}
