import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/reading/presentation/view_models/reader_zoom_controller.dart';

void main() {
  const width = 400.0;
  late ReaderZoomController zoom;

  setUp(() => zoom = ReaderZoomController());

  test('starts at 1x', () {
    expect(zoom.scale, 1.0);
    expect(zoom.dx, 0.0);
  });

  test('clamps scale to 0.5x-4x', () {
    zoom.zoomTo(10, focalX: 0, width: width);
    expect(zoom.scale, 4.0);
    zoom.zoomTo(0.1, focalX: 0, width: width);
    expect(zoom.scale, 0.5);
  });

  test('keeps the focal point fixed when zooming in', () {
    zoom.zoomTo(2, focalX: 300, width: width);
    // content x at focal = (300 - dx) / 2 must still be 300.
    expect((300 - zoom.dx) / 2, closeTo(300, 0.001));
  });

  test('below 1x the content is centered and stays at the chosen scale', () {
    zoom.zoomTo(0.5, focalX: 0, width: width);
    expect(zoom.dx, 100);
    zoom.snap(width: width);
    expect(zoom.scale, 0.5);
  });

  test('snaps to 1x only near 1x', () {
    zoom.zoomTo(1.05, focalX: 0, width: width);
    zoom.snap(width: width);
    expect(zoom.scale, 1.0);
    expect(zoom.dx, 0.0);
    zoom.zoomTo(1.5, focalX: 0, width: width);
    zoom.snap(width: width);
    expect(zoom.scale, 1.5);
  });

  test('pan is clamped to content bounds and ignored at 1x', () {
    zoom.panBy(50, width: width);
    expect(zoom.dx, 0.0);
    zoom.zoomTo(2, focalX: 0, width: width);
    zoom.panBy(100, width: width);
    expect(zoom.dx, 0.0);
    zoom.panBy(-1000, width: width);
    expect(zoom.dx, -400);
  });

  test('double tap toggles between 1x and 2x', () {
    zoom.toggleAt(200, width: width);
    expect(zoom.scale, 2.0);
    zoom.toggleAt(200, width: width);
    expect(zoom.scale, 1.0);
    expect(zoom.dx, 0.0);
  });

  test('reset returns to 1x and notifies', () {
    var calls = 0;
    zoom.addListener(() => calls++);
    zoom.zoomTo(3, focalX: 100, width: width);
    zoom.reset();
    expect(zoom.scale, 1.0);
    expect(zoom.dx, 0.0);
    expect(calls, 2);
  });
}
