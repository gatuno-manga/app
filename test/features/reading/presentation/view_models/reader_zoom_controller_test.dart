import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/reading/presentation/view_models/reader_zoom_controller.dart';

void main() {
  const width = 400.0;
  late ReaderZoomController zoom;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    zoom = ReaderZoomController(ScrollController())
      ..resize(const Size(width, 600));
  });

  test('starts at 1x', () {
    expect(zoom.scale, 1.0);
    expect(zoom.dx, 0.0);
  });

  test('clamps scale to 0.5x-4x', () {
    zoom.zoomTo(10, focal: const Offset(0, 0));
    expect(zoom.scale, 4.0);
    zoom.zoomTo(0.1, focal: const Offset(0, 0));
    expect(zoom.scale, 0.5);
  });

  test('keeps the focal point fixed when zooming in', () {
    zoom.zoomTo(2, focal: const Offset(300, 0));
    // content x at focal = (300 - dx) / 2 must still be 300.
    expect((300 - zoom.dx) / 2, closeTo(300, 0.001));
  });

  test('below 1x the content is centered and stays at the chosen scale', () {
    zoom.zoomTo(0.5, focal: const Offset(0, 0));
    expect(zoom.dx, 100);
    zoom.snap();
    expect(zoom.scale, 0.5);
  });

  test('snaps to 1x only near 1x', () {
    zoom.zoomTo(1.05, focal: const Offset(0, 0));
    zoom.snap();
    expect(zoom.scale, 1.0);
    expect(zoom.dx, 0.0);
    zoom.zoomTo(1.5, focal: const Offset(0, 0));
    zoom.snap();
    expect(zoom.scale, 1.5);
  });

  test('pan is clamped to content bounds and ignored at 1x', () {
    zoom.panBy(50);
    expect(zoom.dx, 0.0);
    zoom.zoomTo(2, focal: const Offset(0, 0));
    zoom.panBy(100);
    expect(zoom.dx, 0.0);
    zoom.panBy(-1000);
    expect(zoom.dx, -400);
  });

  test('double tap toggles between 1x and 2x', () {
    zoom.toggleAt(const Offset(200, 0));
    expect(zoom.scale, 2.0);
    zoom.toggleAt(const Offset(200, 0));
    expect(zoom.scale, 1.0);
    expect(zoom.dx, 0.0);
  });

  test('reset returns to 1x and notifies', () {
    var calls = 0;
    zoom.addListener(() => calls++);
    zoom.zoomTo(3, focal: const Offset(100, 0));
    zoom.reset();
    expect(zoom.scale, 1.0);
    expect(zoom.dx, 0.0);
    expect(calls, 2);
  });

  testWidgets('re-clamps the pan offset when the width shrinks', (
    tester,
  ) async {
    zoom.zoomTo(2, focal: Offset.zero);
    zoom.panBy(-400); // dx == -400 (right edge of 800px content)
    zoom.resize(const Size(200, 600));
    WidgetsBinding.instance.scheduleFrame(); // resize runs during layout
    await tester.pump();
    expect(zoom.dx, -200);
  });
}
