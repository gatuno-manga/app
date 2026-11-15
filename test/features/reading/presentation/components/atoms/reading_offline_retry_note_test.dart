import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/reading/presentation/components/atoms/reading_offline_retry_note.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  Visibility visibility(WidgetTester tester) =>
      tester.widget<Visibility>(find.byType(Visibility));

  testWidgets('hidden until a retry fails, keeping its space', (tester) async {
    await tester.pumpApp(
      const Column(children: [ReadingOfflineRetryNote(failures: 0)]),
    );
    final hidden = tester.getSize(find.byType(ReadingOfflineRetryNote));

    expect(visibility(tester).visible, isFalse);
    expect(visibility(tester).maintainSize, isTrue);

    await tester.pumpApp(
      const Column(children: [ReadingOfflineRetryNote(failures: 1)]),
    );

    expect(visibility(tester).visible, isTrue);
    expect(find.text('Still offline.'), findsOneWidget);
    expect(tester.getSize(find.byType(ReadingOfflineRetryNote)), hidden);
  });

  testWidgets('each failure is a new live region', (tester) async {
    await tester.pumpApp(
      const Column(children: [ReadingOfflineRetryNote(failures: 1)]),
    );
    final first = tester.element(find.byKey(const ValueKey(1)));

    await tester.pumpApp(
      const Column(children: [ReadingOfflineRetryNote(failures: 2)]),
    );

    expect(find.byKey(const ValueKey(1)), findsNothing);
    final second = find.byKey(const ValueKey(2));
    expect(tester.element(second), isNot(same(first)));
    expect(tester.widget<Semantics>(second).properties.liveRegion, isTrue);
  });
}
