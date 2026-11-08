import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/reading/presentation/components/molecules/zoomable_viewport.dart';
import 'package:gatuno/features/reading/presentation/view_models/reader_zoom_controller.dart';

void main() {
  late ReaderZoomController zoom;
  late ScrollController scroll;

  setUp(() {
    zoom = ReaderZoomController();
    scroll = ScrollController();
  });

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      home: SizedBox(
        width: 400,
        height: 600,
        child: ZoomableViewport(
          zoom: zoom,
          scrollController: scroll,
          builder: (context, physics) => ListView.builder(
            controller: scroll,
            physics: physics,
            itemCount: 20,
            itemBuilder: (_, i) => SizedBox(height: 300, child: Text('$i')),
          ),
        ),
      ),
    ),
  );

  testWidgets('pinch out zooms in, release near 1x snaps back', (tester) async {
    await pump(tester);
    final a = await tester.startGesture(const Offset(150, 300));
    final b = await tester.startGesture(const Offset(250, 300));
    await b.moveTo(const Offset(350, 300)); // span 100 -> 200
    await tester.pump();
    expect(zoom.scale, closeTo(2.0, 0.01));
    await b.moveTo(const Offset(255, 300)); // back near 1x
    await a.up();
    await b.up();
    await tester.pump();
    expect(zoom.scale, 1.0);
  });

  testWidgets('pinch beyond limits is clamped', (tester) async {
    await pump(tester);
    final a = await tester.startGesture(const Offset(190, 300));
    final b = await tester.startGesture(const Offset(210, 300));
    await b.moveTo(const Offset(600, 300));
    await tester.pump();
    expect(zoom.scale, 4.0);
    await a.up();
    await b.up();
  });

  testWidgets('list scrolling is locked only while pinching', (tester) async {
    await pump(tester);
    ScrollPhysics? physics() =>
        tester.widget<ListView>(find.byType(ListView)).physics;
    expect(physics(), isNull);
    final a = await tester.startGesture(const Offset(150, 300));
    final b = await tester.startGesture(const Offset(250, 300));
    await tester.pump();
    expect(physics(), isA<NeverScrollableScrollPhysics>());
    await a.up();
    await b.up();
    await tester.pump();
    expect(physics(), isNull);
    await tester.drag(find.byType(ListView), const Offset(0, -100));
    await tester.pump();
    expect(scroll.offset, greaterThan(0));
  });

  testWidgets('one-finger drag pans horizontally when zoomed', (tester) async {
    await pump(tester);
    zoom.zoomTo(2, focalX: 0, width: 400);
    await tester.pump();
    await tester.dragFrom(const Offset(200, 300), const Offset(-100, 0));
    await tester.pump();
    expect(zoom.dx, closeTo(-100, 1));
  });
}
