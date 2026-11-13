import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/theme.dart';
import 'package:gatuno/features/reading/data/data_sources/reader_preferences_storage.dart';
import 'package:gatuno/features/reading/domain/entities/reader_preferences.dart';
import 'package:gatuno/features/reading/domain/use_cases/reader_preferences_service.dart';
import 'package:gatuno/features/reading/presentation/components/molecules/reader_switch_row.dart';
import 'package:gatuno/features/reading/presentation/components/organisms/reader_accessibility_sheet.dart';
import 'package:gatuno/features/reading/presentation/components/organisms/reader_settings_sheet.dart';
import 'package:gatuno/features/reading/presentation/components/organisms/text_reader_settings_section.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  late ReaderPreferencesService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = ReaderPreferencesService(ReaderPreferencesStorage());
  });

  tearDown(() => service.dispose());

  Future<void> openSheet(WidgetTester tester) async {
    await tester.pumpApp(
      Provider<ReaderPreferencesService>.value(
        value: service,
        child: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => ReaderAccessibilitySheet.show(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
      theme: AppTheme.lightTheme,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  final dyslexiaSwitch = find.byType(Switch).first;
  Finder rowSwitch(String title) => find.descendant(
    of: find.widgetWithText(ReaderSwitchRow, title),
    matching: find.byType(Switch),
  );

  Future<void> tapScrolled(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  group('ReaderAccessibilitySheet', () {
    testWidgets('shows the preset card, the theme picker and every row', (
      tester,
    ) async {
      await openSheet(tester);

      expect(find.text('Accessibility'), findsOneWidget);
      expect(find.text('Dyslexia mode'), findsOneWidget);
      expect(find.text('Reading theme'), findsNothing); // label is semantic
      expect(find.text('Font'), findsOneWidget);
      expect(find.text('Letter spacing (+0%)'), findsOneWidget);
      expect(find.text('Word spacing (+0%)'), findsOneWidget);
      expect(find.text('Line width (no limit)'), findsOneWidget);
      expect(find.text('Alignment'), findsOneWidget);
      expect(find.text('No italics'), findsWidgets);
      expect(find.text('Reading ruler'), findsWidgets);
    });

    testWidgets('the dyslexia switch applies the preset', (tester) async {
      await openSheet(tester);

      await tester.tap(dyslexiaSwitch);
      await tester.pumpAndSettle();

      final prefs = service.current;
      expect(prefs.dyslexiaMode, isTrue);
      expect(prefs.theme, ReaderTheme.cream);
      expect(prefs.text.fontFamily, ReaderFontFamily.lexend);
      expect(find.text('Letter spacing (+5%)'), findsOneWidget);
      expect(find.text('Word spacing (+16%)'), findsOneWidget);
      expect(find.text('Line width (60 characters)'), findsOneWidget);
      expect(find.text('Letters +5%'), findsOneWidget);
      expect(find.text('Words +16%'), findsOneWidget);
      expect(find.text('~60 characters'), findsOneWidget);
      expect(find.text('Cream background'), findsOneWidget);
    });

    testWidgets('turning the switch off restores the previous values', (
      tester,
    ) async {
      await service.update(
        (p) => p.copyWith(
          theme: ReaderTheme.sepia,
          text: p.text.copyWith(fontFamily: ReaderFontFamily.sans),
        ),
      );
      final before = service.current;
      await openSheet(tester);

      await tester.tap(dyslexiaSwitch);
      await tester.pumpAndSettle();
      await tester.tap(dyslexiaSwitch);
      await tester.pumpAndSettle();

      expect(service.current, before);
      expect(find.text('Letters +5%'), findsNothing);
    });

    testWidgets('an edit while the preset is on keeps it on and shows in the '
        'chips', (tester) async {
      await openSheet(tester);
      await tester.tap(dyslexiaSwitch);
      await tester.pumpAndSettle();

      await tapScrolled(tester, find.byTooltip('Increase word spacing'));

      expect(service.current.dyslexiaMode, isTrue);
      expect(service.current.text.wordSpacing, 0.18);
      expect(find.text('Words +18%'), findsOneWidget);
    });

    testWidgets('steppers change spacing and line width and disable at the '
        'limits', (tester) async {
      await openSheet(tester);

      await tapScrolled(tester, find.byTooltip('Increase letter spacing'));
      await tapScrolled(tester, find.byTooltip('Increase line width'));
      expect(service.current.text.letterSpacing, 0.01);
      expect(service.current.text.lineWidth, 40);

      await tapScrolled(tester, find.byTooltip('Decrease line width'));
      expect(service.current.text.lineWidth, isNull);

      // Off is the lower limit: the decrease button does nothing.
      await tapScrolled(tester, find.byTooltip('Decrease line width'));
      expect(service.current.text.lineWidth, isNull);
      await tapScrolled(tester, find.byTooltip('Decrease word spacing'));
      expect(service.current.text.wordSpacing, 0);
    });

    testWidgets('the italics and ruler switches persist', (tester) async {
      await openSheet(tester);

      await tapScrolled(tester, rowSwitch('No italics'));
      await tapScrolled(tester, rowSwitch('Reading ruler'));

      expect(service.current.text.suppressItalics, isTrue);
      expect(service.current.text.readingRuler, isTrue);
      // Neither is the preset: the preset stays off.
      expect(service.current.dyslexiaMode, isFalse);
    });

    testWidgets('is reachable from the reader settings sheet', (tester) async {
      await tester.pumpApp(
        Provider<ReaderPreferencesService>.value(
          value: service,
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => ReaderSettingsSheet.show(
                  context,
                  sections: TextReaderSettingsSection.sectionsFor(service),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
        theme: AppTheme.lightTheme,
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tapScrolled(tester, find.text('Accessibility'));

      expect(find.text('Dyslexia mode'), findsOneWidget);
    });
  });
}
