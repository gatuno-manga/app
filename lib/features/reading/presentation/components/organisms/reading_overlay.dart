import 'package:flutter/material.dart';
import '../../../domain/entities/reading_chapter.dart';
import '../molecules/reading_top_bar.dart';
import '../molecules/reading_bottom_bar.dart';

class ReadingOverlay extends StatelessWidget {
  final ReadingChapter chapter;

  const ReadingOverlay({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Column(
      children: [
        ReadingTopBar(chapter: chapter, topPadding: topPadding),
        const Spacer(),
        ReadingBottomBar(chapter: chapter, bottomPadding: bottomPadding),
      ],
    );
  }
}
