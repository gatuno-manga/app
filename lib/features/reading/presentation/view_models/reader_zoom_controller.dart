import 'package:flutter/foundation.dart';

/// Zoom state for the image reader: a horizontal-only transform whose
/// vertical movement is delegated to the list's own scrolling.
class ReaderZoomController extends ChangeNotifier {
  static const double minScale = 0.5;
  static const double maxScale = 4.0;
  static const double doubleTapScale = 2.0;
  static const double snapThreshold = 0.1;

  double _scale = 1.0;
  double _dx = 0.0;

  double get scale => _scale;

  /// Left edge of the content, relative to the viewport.
  double get dx => _dx;

  /// Scales to [target] keeping the point at [focalX] (viewport coordinates)
  /// fixed. Returns the effective ratio between the new and previous scale.
  double zoomTo(
    double target, {
    required double focalX,
    required double width,
  }) {
    final next = target.clamp(minScale, maxScale);
    final ratio = next / _scale;
    _scale = next;
    _setDx(focalX - (focalX - _dx) * ratio, width);
    notifyListeners();
    return ratio;
  }

  void panBy(double deltaX, {required double width}) {
    if (_scale <= 1.0) return;
    _setDx(_dx + deltaX, width);
    notifyListeners();
  }

  /// Magnet: a scale close to 1x settles at exactly 1x.
  void snap({required double width}) {
    if ((_scale - 1.0).abs() < snapThreshold && _scale != 1.0) {
      zoomTo(1.0, focalX: width / 2, width: width);
    }
  }

  /// Returns the ratio applied, to let the caller anchor vertical scroll.
  double toggleAt(double focalX, {required double width}) {
    final target = _scale == 1.0 ? doubleTapScale : 1.0;
    return zoomTo(target, focalX: focalX, width: width);
  }

  void reset() {
    if (_scale == 1.0 && _dx == 0.0) return;
    _scale = 1.0;
    _dx = 0.0;
    notifyListeners();
  }

  void _setDx(double value, double width) {
    final contentWidth = width * _scale;
    _dx = contentWidth <= width
        ? (width - contentWidth) / 2
        : value.clamp(width - contentWidth, 0.0);
  }
}
