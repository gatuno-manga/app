import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/shared/components/atoms/app_icon_segment.dart';
import 'package:gatuno/shared/components/molecules/app_icon_segmented_control.dart';

enum _Mode { a, b, c }

void main() {
  const options = [
    AppIconSegmentOption(value: _Mode.a, icon: Icons.grid_view, label: 'A'),
    AppIconSegmentOption(value: _Mode.b, icon: Icons.view_list, label: 'B'),
    AppIconSegmentOption(value: _Mode.c, icon: Icons.image, label: 'C'),
  ];

  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('renders one segment per option with the current one selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        AppIconSegmentedControl<_Mode>(
          options: options,
          value: _Mode.b,
          onChanged: (_) {},
        ),
      ),
    );

    final segments = tester
        .widgetList<AppIconSegment>(find.byType(AppIconSegment))
        .toList();
    expect(segments.length, 3);
    expect(segments.map((s) => s.selected), [false, true, false]);
  });

  testWidgets('calls onChanged with the tapped value', (tester) async {
    _Mode? changed;
    await tester.pumpWidget(
      wrap(
        AppIconSegmentedControl<_Mode>(
          options: options,
          value: _Mode.a,
          onChanged: (v) => changed = v,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.image));

    expect(changed, _Mode.c);
  });

  testWidgets('does not call onChanged for the already selected value', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      wrap(
        AppIconSegmentedControl<_Mode>(
          options: options,
          value: _Mode.a,
          onChanged: (_) => calls++,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.grid_view));

    expect(calls, 0);
  });
}
