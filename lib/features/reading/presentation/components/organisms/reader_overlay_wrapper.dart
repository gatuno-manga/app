import 'package:flutter/material.dart';
import '../../../domain/entities/reading_chapter.dart';
import 'reading_bottom_overlay.dart';
import 'reading_top_overlay.dart';

class ReaderOverlayWrapper extends StatefulWidget {
  final Widget child;
  final ReadingChapter chapter;

  const ReaderOverlayWrapper({
    super.key,
    required this.child,
    required this.chapter,
  });

  @override
  State<ReaderOverlayWrapper> createState() => _ReaderOverlayWrapperState();
}

class _ReaderOverlayWrapperState extends State<ReaderOverlayWrapper> {
  bool _showOverlay = false;

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: _toggleOverlay,
          behavior: HitTestBehavior.opaque,
          child: widget.child,
        ),
        ReadingTopOverlay(
          showOverlay: _showOverlay,
          chapter: widget.chapter,
        ),
        ReadingBottomOverlay(
          showOverlay: _showOverlay,
          chapter: widget.chapter,
        ),
      ],
    );
  }
}
