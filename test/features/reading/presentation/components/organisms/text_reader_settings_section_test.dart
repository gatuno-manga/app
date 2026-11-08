import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/reading/domain/entities/reader_preferences.dart';
import 'package:gatuno/features/reading/presentation/components/organisms/text_reader_settings_section.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  late List<ReaderPreferences> changes;

  setUp(() => changes = []);

  Future<void> pump(WidgetTester tester, ReaderPreferences prefs) =>
      tester.pumpApp(
        Scaffold(
          body: SingleChildScrollView(
            child: TextReaderSettingsSection(
              preferences: prefs,
              onChanged: changes.add,
            ),
          ),
        ),
      );

  group('TextReaderSettingsSection', () {
    testWidgets('renders the four text rows', (tester) async {
      await pump(tester, ReaderPreferences.defaults);

      expect(find.text('Font'), findsOneWidget);
      expect(find.text('Font size (19px)'), findsOneWidget);
      expect(find.text('Line spacing (1.8)'), findsOneWidget);
      expect(find.text('Alignment'), findsOneWidget);
    });

    testWidgets('font size stepper moves by one and clamps at the bounds', (
      tester,
    ) async {
      await pump(tester, ReaderPreferences.defaults);

      await tester.tap(find.byTooltip('Increase').first);
      await tester.tap(find.byTooltip('Decrease').first);

      expect(changes.map((p) => p.text.fontSize), [20, 18]);

      await pump(
        tester,
        ReaderPreferences.defaults.copyWith(
          text: TextReaderPreferences.defaults.copyWith(fontSize: 28),
        ),
      );
      final plus = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.add).first,
      );
      expect(plus.onPressed, isNull);
    });

    testWidgets('line height stepper moves by 0.1 without float noise', (
      tester,
    ) async {
      await pump(tester, ReaderPreferences.defaults);

      await tester.tap(find.byTooltip('Increase').last);
      await tester.tap(find.byTooltip('Decrease').last);

      expect(changes.map((p) => p.text.lineHeight), [1.9, 1.7]);

      await pump(
        tester,
        ReaderPreferences.defaults.copyWith(
          text: TextReaderPreferences.defaults.copyWith(lineHeight: 1.2),
        ),
      );
      final minus = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.remove).last,
      );
      expect(minus.onPressed, isNull);
    });

    testWidgets('font family and alignment pickers report the choice', (
      tester,
    ) async {
      await pump(tester, ReaderPreferences.defaults);

      await tester.tap(find.text('Serif'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OpenDyslexic').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Left'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Justified').last);
      await tester.pumpAndSettle();

      expect(changes.map((p) => p.text.fontFamily), [
        ReaderFontFamily.openDyslexic,
        ReaderFontFamily.serif,
      ]);
      expect(changes.map((p) => p.text.alignment), [
        ReaderTextAlignment.left,
        ReaderTextAlignment.justify,
      ]);
    });
  });
}
