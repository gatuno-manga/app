import 'package:flutter/material.dart';
import '../../../domain/entities/reading_chapter.dart';
import 'reading_bottom_overlay.dart';
import 'reading_top_overlay.dart';

class ReaderOverlayWrapper extends StatefulWidget {
  final Widget child;
  final ReadingChapter chapter;

  /// Called with the local position of a double tap. When set, a single tap
  /// is confirmed after the double-tap window (~300ms).
  final void Function(Offset position)? onDoubleTap;

  /// Shown as a settings action in both bars when set.
  final VoidCallback? onSettingsPressed;

  const ReaderOverlayWrapper({
    super.key,
    required this.child,
    required this.chapter,
    this.onDoubleTap,
    this.onSettingsPressed,
  });

  @override
  State<ReaderOverlayWrapper> createState() => _ReaderOverlayWrapperState();
}

class _ReaderOverlayWrapperState extends State<ReaderOverlayWrapper> {
  bool _showOverlay = false;
  Offset _doubleTapPosition = Offset.zero;

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
    });
  }

  @override
  Widget build(BuildContext context) {
    final onDoubleTap = widget.onDoubleTap;
    return Stack(
      children: [
        GestureDetector(
          onTap: _toggleOverlay,
          onDoubleTapDown: onDoubleTap == null
              ? null
              : (details) => _doubleTapPosition = details.localPosition,
          onDoubleTap: onDoubleTap == null
              ? null
              : () => onDoubleTap(_doubleTapPosition),
          behavior: HitTestBehavior.opaque,
          child: widget.child,
        ),
        ReadingTopOverlay(
          showOverlay: _showOverlay,
          chapter: widget.chapter,
          onSettingsPressed: widget.onSettingsPressed,
        ),
        ReadingBottomOverlay(
          showOverlay: _showOverlay,
          chapter: widget.chapter,
          onSettingsPressed: widget.onSettingsPressed,
        ),
      ],
    );
  }
}
