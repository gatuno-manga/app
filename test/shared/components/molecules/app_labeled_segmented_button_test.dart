import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/shared/components/molecules/app_labeled_segmented_button.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  const segments = [
    ButtonSegment(value: 1, label: Text('One')),
    ButtonSegment(value: 2, label: Text('Two')),
  ];

  testWidgets('shows the label and reports the tapped segment', (tester) async {
    int? changed;
    await tester.pumpWidget(
      wrap(
        AppLabeledSegmentedButton<int>(
          label: 'Count',
          segments: segments,
          value: 1,
          onChanged: (v) => changed = v,
        ),
      ),
    );

    expect(find.text('Count'), findsOneWidget);
    await tester.tap(find.text('Two'));

    expect(changed, 2);
  });

  testWidgets('is disabled and dims the label when onChanged is null', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const AppLabeledSegmentedButton<int>(
          label: 'Count',
          segments: segments,
          value: 1,
        ),
      ),
    );

    final button = tester.widget<SegmentedButton<int>>(
      find.byType(SegmentedButton<int>),
    );
    expect(button.onSelectionChanged, isNull);
    final label = tester.widget<Text>(find.text('Count'));
    final context = tester.element(find.text('Count'));
    expect(
      label.style?.color,
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
    );
  });

  testWidgets('shows the description and checks the selected segment', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        AppLabeledSegmentedButton<int>(
          label: 'Count',
          description: 'How many',
          segments: segments,
          value: 2,
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('How many'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('expanded stretches the segments to the full width', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        AppLabeledSegmentedButton<int>(
          label: 'Count',
          segments: segments,
          value: 1,
          expanded: true,
          onChanged: (_) {},
        ),
      ),
    );

    final width = tester.getSize(find.byType(SegmentedButton<int>)).width;
    expect(
      width,
      tester.view.physicalSize.width / tester.view.devicePixelRatio,
    );
  });
}
