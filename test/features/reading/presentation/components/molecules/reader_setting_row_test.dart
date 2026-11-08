import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/reading/presentation/components/molecules/reader_setting_row.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  testWidgets('ReaderSettingRow shows icon, texts and the trailing control', (
    tester,
  ) async {
    await tester.pumpApp(
      const Scaffold(
        body: ReaderSettingRow(
          icon: Icons.text_fields,
          title: 'Font',
          subtitle: 'Text family',
          trailing: Text('Serif'),
        ),
      ),
    );

    expect(find.byIcon(Icons.text_fields), findsOneWidget);
    expect(find.text('Font'), findsOneWidget);
    expect(find.text('Text family'), findsOneWidget);
    expect(find.text('Serif'), findsOneWidget);
  });
}
