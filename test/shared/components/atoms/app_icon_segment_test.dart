import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/shared/components/atoms/app_icon_segment.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('exposes its label as tooltip and selected semantics', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const AppIconSegment(
          icon: Icons.grid_view,
          label: 'Grid',
          selected: true,
        ),
      ),
    );

    expect(find.byTooltip('Grid'), findsOneWidget);
    expect(
      tester.getSemantics(find.byIcon(Icons.grid_view)),
      matchesSemantics(
        hasSelectedState: true,
        isSelected: true,
        isButton: true,
        hasTapAction: false,
        label: 'Grid',
      ),
    );
  });

  testWidgets('calls onTap when tapped', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(
        AppIconSegment(
          icon: Icons.view_list,
          label: 'List',
          selected: false,
          onTap: () => taps++,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.view_list));

    expect(taps, 1);
  });

  testWidgets('paints the selected segment in the primary color', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const AppIconSegment(
          icon: Icons.image,
          label: 'Covers',
          selected: true,
        ),
      ),
    );

    final context = tester.element(find.byIcon(Icons.image));
    final icon = tester.widget<Icon>(find.byIcon(Icons.image));
    expect(icon.color, Theme.of(context).colorScheme.onPrimary);
  });
}
