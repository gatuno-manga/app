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
    return Container(
      padding: EdgeInsets.only(top: topPadding, left: 8, right: 8, bottom: 8),
      color: Colors.black.withValues(alpha: 0.8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chapter.bookTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  chapter.title ?? 'Chapter ${chapter.index}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
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
