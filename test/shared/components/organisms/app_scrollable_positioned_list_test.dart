import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/shared/components/organisms/app_scrollable_positioned_list.dart';

void main() {
  group('AppScrollablePositionedList', () {
    testWidgets('reports last index when scrolled to bottom', (tester) async {
      int? reportedIndex;
      final itemCount = 20;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 500,
              child: AppScrollablePositionedList(
                itemCount: itemCount,
                onVisibleIndexChanged: (index) => reportedIndex = index,
                itemBuilder: (context, index) {
                  // Make the last item very small
                  final height = (index == itemCount - 1) ? 1.0 : 400.0;
                  return SizedBox(height: height, child: Text('Item $index'));
                },
              ),
            ),
          ),
        ),
      );

      // Scroll to the absolute bottom
      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(
        find.text('Item ${itemCount - 1}'),
        500.0,
      );

      // Force scroll to reach the very end
      await tester.drag(scrollable, const Offset(0, -1000));
      await tester.pumpAndSettle();

      expect(reportedIndex, itemCount - 1);
    });
  });
}
