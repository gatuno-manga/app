import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/shared/utils/load_more_listener.dart';

void main() {
  Widget build({
    required VoidCallback onLoadMore,
    bool enabled = true,
    required ScrollController controller,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: LoadMoreListener(
          onLoadMore: onLoadMore,
          enabled: enabled,
          threshold: 100,
          child: ListView.builder(
            controller: controller,
            itemExtent: 100,
            itemCount: 30,
            itemBuilder: (_, i) => Text('item $i'),
          ),
        ),
      ),
    );
  }

  testWidgets('fires once when the end comes within the threshold', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    var calls = 0;
    await tester.pumpWidget(
      build(onLoadMore: () => calls++, controller: controller),
    );

    controller.jumpTo(controller.position.maxScrollExtent - 50);
    await tester.pump();
    controller.jumpTo(controller.position.maxScrollExtent - 20);
    await tester.pump();

    expect(calls, 1);
  });

  testWidgets('re-arms after scrolling away from the end', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    var calls = 0;
    await tester.pumpWidget(
      build(onLoadMore: () => calls++, controller: controller),
    );

    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();
    controller.jumpTo(0);
    await tester.pump();
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();

    expect(calls, 2);
  });

  testWidgets('does nothing while disabled', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    var calls = 0;
    await tester.pumpWidget(
      build(onLoadMore: () => calls++, enabled: false, controller: controller),
    );

    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();

    expect(calls, 0);
  });

  testWidgets('does not fire far from the end', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    var calls = 0;
    await tester.pumpWidget(
      build(onLoadMore: () => calls++, controller: controller),
    );

    controller.jumpTo(300);
    await tester.pump();

    expect(calls, 0);
  });

  testWidgets('re-arms when it becomes enabled again at the end of the list', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    var calls = 0;
    Widget app({required bool enabled}) => build(
      onLoadMore: () => calls++,
      enabled: enabled,
      controller: controller,
    );
    await tester.pumpWidget(app(enabled: true));
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();
    expect(calls, 1);

    // A load starts (disabled) and fails; the user is still at the end.
    await tester.pumpWidget(app(enabled: false));
    await tester.pumpWidget(app(enabled: true));
    controller.jumpTo(controller.position.maxScrollExtent - 1);
    await tester.pump();

    expect(calls, 2);
  });
}
