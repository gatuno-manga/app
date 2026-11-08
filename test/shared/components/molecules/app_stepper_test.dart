import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/shared/components/molecules/app_stepper.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('AppStepper', () {
    testWidgets('calls the callbacks on tap', (tester) async {
      var decrements = 0;
      var increments = 0;
      await tester.pumpApp(
        Scaffold(
          body: AppStepper(
            onDecrement: () => decrements++,
            onIncrement: () => increments++,
            decrementTooltip: 'Less',
            incrementTooltip: 'More',
          ),
        ),
      );

      await tester.tap(find.byTooltip('Less'));
      await tester.tap(find.byTooltip('More'));
      await tester.tap(find.byTooltip('More'));

      expect(decrements, 1);
      expect(increments, 2);
    });

    testWidgets('a null callback disables that side', (tester) async {
      await tester.pumpApp(
        Scaffold(
          body: AppStepper(
            onDecrement: null,
            onIncrement: () {},
            decrementTooltip: 'Less',
            incrementTooltip: 'More',
          ),
        ),
      );

      final minus = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.remove),
      );
      final plus = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.add),
      );
      expect(minus.onPressed, isNull);
      expect(plus.onPressed, isNotNull);
    });
  });
}
