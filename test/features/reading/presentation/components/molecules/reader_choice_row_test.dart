import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/reading/presentation/components/molecules/reader_choice_row.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  testWidgets('ReaderChoiceRow shows the current label and reports a pick', (
    tester,
  ) async {
    String? picked;
    await tester.pumpApp(
      Scaffold(
        body: ReaderChoiceRow<String>(
          icon: Icons.text_fields,
          title: 'Font',
          subtitle: 'Text family',
          value: 'serif',
          options: const [
            ReaderChoice('serif', 'Serif'),
            ReaderChoice('sans', 'Sans'),
          ],
          onChanged: (value) => picked = value,
        ),
      ),
    );

    expect(find.text('Serif'), findsOneWidget);
    expect(find.text('Sans'), findsNothing);

    await tester.tap(find.text('Serif'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sans').last);
    await tester.pumpAndSettle();

    expect(picked, 'sans');
  });
}
