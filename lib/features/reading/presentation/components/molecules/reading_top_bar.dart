import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/reading_chapter.dart';

class ReadingTopBar extends StatelessWidget {
  final ReadingChapter chapter;
  final double topPadding;

  const ReadingTopBar({
    super.key,
    required this.chapter,
    required this.topPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.only(top: topPadding, left: 8, right: 8, bottom: 8),
      color: theme.colorScheme.surface.withValues(alpha: 0.9),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chapter.bookTitle,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  chapter.title ?? 'Chapter ${chapter.index}',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
