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
  final ScrollController scrollController;
  final Widget Function(BuildContext context, ScrollPhysics? physics) builder;

  const ZoomableViewport({
    super.key,
    required this.zoom,
    required this.scrollController,
    required this.builder,
  });

  @override
  State<ZoomableViewport> createState() => _ZoomableViewportState();
}

class _ZoomableViewportState extends State<ZoomableViewport> {
  final Map<int, Offset> _pointers = {};
  double _width = 0;
  double _height = 0;

  bool get _pinching => _pointers.length >= 2;

  void _anchorScroll(double ratio, double focalY) {
    final controller = widget.scrollController;
    if (!controller.hasClients || ratio == 1.0) return;
    final target = (controller.offset + focalY) * ratio - focalY;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.hasClients) return;
      controller.jumpTo(target.clamp(0.0, controller.position.maxScrollExtent));
    });
  }

  void _onPointerDown(PointerDownEvent event) {
    final wasPinching = _pinching;
    _pointers[event.pointer] = event.localPosition;
    if (_pinching != wasPinching) setState(() {});
  }

  void _onPointerMove(PointerMoveEvent event) {
    final previous = _pointers[event.pointer];
    if (previous == null) return;
    if (_pinching) {
      final before = _pointers.values.toList();
      _pointers[event.pointer] = event.localPosition;
      final after = _pointers.values.toList();
      final oldSpan = (before[0] - before[1]).distance;
      final newSpan = (after[0] - after[1]).distance;
      if (oldSpan == 0) return;
      final oldFocal = (before[0] + before[1]) / 2;
      final focal = (after[0] + after[1]) / 2;
      final ratio = widget.zoom.zoomTo(
        widget.zoom.scale * newSpan / oldSpan,
        focalX: focal.dx,
        width: _width,
      );
      widget.zoom.panBy(focal.dx - oldFocal.dx, width: _width);
      _anchorScroll(ratio, focal.dy);
    } else {
      _pointers[event.pointer] = event.localPosition;
      widget.zoom.panBy(event.localPosition.dx - previous.dx, width: _width);
    }
  }

  void _onPointerEnd(PointerEvent event) {
    final wasPinching = _pinching;
    _pointers.remove(event.pointer);
    if (wasPinching && !_pinching) {
      final ratio = widget.zoom.scale;
      widget.zoom.snap(width: _width);
      _anchorScroll(widget.zoom.scale / ratio, _height / 2);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _width = constraints.maxWidth;
        _height = constraints.maxHeight;
        return Listener(
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerEnd,
          onPointerCancel: _onPointerEnd,
          child: ClipRect(
            child: ListenableBuilder(
              listenable: widget.zoom,
              builder: (context, _) => Stack(
                children: [
                  Positioned(
                    left: widget.zoom.dx,
                    width: _width * widget.zoom.scale,
                    top: 0,
                    bottom: 0,
                    child: widget.builder(
                      context,
                      _pinching ? const NeverScrollableScrollPhysics() : null,
                    ),
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
