import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/book.dart';
import '../atoms/book_cover.dart';
import '../atoms/book_title.dart';
import '../atoms/book_type_badge.dart';

/// Grid card: cover with the title below it (Figma `Livro/Card`).
class BookCard extends StatelessWidget {
  /// Figma Livro/Card, grid variant: 171x295.
  static const double aspectRatio = 0.58;

  final Book book;

  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w600,
    );
    // Always reserve two title lines so covers in one grid row stay level.
    // Flutter scales the font size and then applies the line height.
    final titleHeight =
        MediaQuery.textScalerOf(context).scale(titleStyle?.fontSize ?? 12) *
        (titleStyle?.height ?? 1.3) *
        2;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/books/${book.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
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
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: SizedBox(
                height: titleHeight,
                child: BookTitle(title: book.title.value, style: titleStyle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
