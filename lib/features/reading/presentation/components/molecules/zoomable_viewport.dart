import 'package:flutter/material.dart';

import '../../view_models/reader_zoom_controller.dart';

/// Lays [builder]'s child out at `viewport width * zoom scale`, so zoom is
/// real layout (images grow, the list keeps scrolling vertically) and only
/// horizontal panning is handled here.
///
/// Pinch and one-finger pan are read through a [Listener], so they never
/// compete with the list's own drag or with tap gestures in the gesture arena.
class ZoomableViewport extends StatefulWidget {
  final ReaderZoomController zoom;
  final Widget Function(BuildContext context, ScrollPhysics? physics) builder;

  const ZoomableViewport({
    super.key,
    required this.zoom,
    required this.builder,
  });

  @override
  State<ZoomableViewport> createState() => _ZoomableViewportState();
}

class _ZoomableViewportState extends State<ZoomableViewport> {
  final Map<int, Offset> _pointers = {};
  bool get _pinching => _pointers.length >= 2;

  void _onPointerDown(PointerDownEvent event) {
    final wasPinching = _pinching;
    _pointers[event.pointer] = event.localPosition;
    if (_pinching != wasPinching) setState(() {});
  }

  void _onPointerMove(PointerMoveEvent event) {
    final previous = _pointers[event.pointer];
    if (previous == null) return;
    if (!_pinching) {
      _pointers[event.pointer] = event.localPosition;
      widget.zoom.panBy(event.localPosition.dx - previous.dx);
      return;
    }
    final before = _pointers.values.toList();
    _pointers[event.pointer] = event.localPosition;
    final after = _pointers.values.toList();
    final oldSpan = (before[0] - before[1]).distance;
    if (oldSpan == 0) return;
    final newSpan = (after[0] - after[1]).distance;
    final oldFocal = (before[0] + before[1]) / 2;
    final focal = (after[0] + after[1]) / 2;
    widget.zoom.pinch(
      widget.zoom.scale * newSpan / oldSpan,
      focal: focal,
      focalDelta: focal.dx - oldFocal.dx,
    );
  }

  void _onPointerEnd(PointerEvent event) {
    final wasPinching = _pinching;
    _pointers.remove(event.pointer);
    if (wasPinching && !_pinching) {
      widget.zoom.snap();
      // Re-enables list scrolling (physics depend on _pinching).
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        widget.zoom.resize(constraints.biggest);
        return Listener(
          // Opaque so pinches starting in the side margins (scale < 1) count.
          behavior: HitTestBehavior.opaque,
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerEnd,
          onPointerCancel: _onPointerEnd,
          child: ClipRect(
            child: ListenableBuilder(
              listenable: widget.zoom,
              // The list is built once per viewport build; zoom changes only
              // move/resize the Positioned around it (no item rebuilds).
              child: widget.builder(
                context,
                _pinching ? const NeverScrollableScrollPhysics() : null,
              ),
              builder: (context, list) => Stack(
                children: [
                  Positioned(
                    left: widget.zoom.dx,
                    width: width * widget.zoom.scale,
                    top: 0,
                    bottom: 0,
                    child: list!,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
