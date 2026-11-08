import 'package:flutter/widgets.dart';

/// Zoom state for the image reader.
///
/// Zoom is real layout (the list is laid out at `viewport width * scale`), so
/// this controller only owns the horizontal offset; vertical movement stays on
/// the list's [ScrollController], which the controller re-anchors on every
/// scale change so the content under the focal point stays put.
class ReaderZoomController extends ChangeNotifier {
  static const double minScale = 0.5;
  static const double maxScale = 4.0;
  static const double doubleTapScale = 2.0;
  static const double snapThreshold = 0.1;

  ScrollController? _scroll;
  Size _viewport = Size.zero;
  double _scale = 1.0;
  double _dx = 0.0;

  double _pendingRatio = 1.0;
  double _pendingFocalY = 0.0;
  bool _anchorScheduled = false;

  double get scale => _scale;

  /// Left edge of the content, relative to the viewport.
  double get dx => _dx;

  /// Binds the list's scroll controller and the viewport size. Called by the
  /// viewport on every layout; a width change re-clamps the pan offset.
  void attach(ScrollController scroll, Size viewport) {
    _scroll = scroll;
    if (viewport.width == _viewport.width) {
      _viewport = viewport;
      return;
    }
    _viewport = viewport;
    // Layout is in progress: notifying must wait for the next frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setDx(_dx);
      notifyListeners();
    });
  }

  /// Scales to [target] keeping [focal] (viewport coordinates) fixed.
  void zoomTo(double target, {required Offset focal}) {
    final next = target.clamp(minScale, maxScale);
    final ratio = next / _scale;
    _scale = next;
    _setDx(focal.dx - (focal.dx - _dx) * ratio);
    _anchorScroll(ratio, focal.dy);
    notifyListeners();
  }

  void panBy(double deltaX) {
    if (_scale <= 1.0) return;
    _setDx(_dx + deltaX);
    notifyListeners();
  }

  /// Magnet: a scale close to 1x settles at exactly 1x. The exact `== 1.0`
  /// comparisons in this class rely on this (and [reset]) producing 1.0.
  void snap() {
    if ((_scale - 1.0).abs() < snapThreshold && _scale != 1.0) {
      zoomTo(1.0, focal: _viewport.center(Offset.zero));
    }
  }

  void toggleAt(Offset focal) {
    zoomTo(_scale == 1.0 ? doubleTapScale : 1.0, focal: focal);
  }

  void reset() {
    if (_scale == 1.0 && _dx == 0.0) return;
    _scale = 1.0;
    _dx = 0.0;
    notifyListeners();
  }

  /// Batches the re-anchoring: several pointer events can arrive per frame,
  /// and each one must compound on the previous, not on a stale offset.
  void _anchorScroll(double ratio, double focalY) {
    final scroll = _scroll;
    if (scroll == null || !scroll.hasClients || ratio == 1.0) return;
    _pendingRatio *= ratio;
    _pendingFocalY = focalY;
    if (_anchorScheduled) return;
    _anchorScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _anchorScheduled = false;
      final applied = _pendingRatio;
      _pendingRatio = 1.0;
      if (!scroll.hasClients) return;
      final target =
          (scroll.offset + _pendingFocalY) * applied - _pendingFocalY;
      scroll.jumpTo(target.clamp(0.0, scroll.position.maxScrollExtent));
    });
  }

  void _setDx(double value) {
    final width = _viewport.width;
    final contentWidth = width * _scale;
    _dx = contentWidth <= width
        ? (width - contentWidth) / 2
        : value.clamp(width - contentWidth, 0.0);
  }
}
