import 'package:flutter/material.dart';
import '../../../domain/entities/reading_chapter.dart';
import '../molecules/reading_top_bar.dart';

class ReadingTopOverlay extends StatelessWidget {
  final bool showOverlay;
  final ReadingChapter chapter;

  const ReadingTopOverlay({
    super.key,
    required this.showOverlay,
    required this.chapter,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        reverseDuration: const Duration(milliseconds: 200),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final offsetAnimation =
              Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                  reverseCurve: Curves.easeIn,
                ),
              );

          return SlideTransition(position: offsetAnimation, child: child);
        },
        child: showOverlay
            ? ReadingTopBar(
                chapter: chapter,
                topPadding: MediaQuery.of(context).padding.top,
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
