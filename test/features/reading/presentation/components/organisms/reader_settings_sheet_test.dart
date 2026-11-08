import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/app_palette.dart';
import 'package:gatuno/core/theme/reader_palette.dart';
import 'package:gatuno/core/theme/theme.dart';
import 'package:gatuno/features/reading/presentation/components/organisms/text_reader_settings_section.dart';
import 'package:gatuno/features/reading/data/data_sources/reader_preferences_storage.dart';
import 'package:gatuno/features/reading/domain/entities/reader_preferences.dart';
import 'package:gatuno/features/reading/domain/use_cases/reader_preferences_service.dart';
import 'package:gatuno/features/reading/presentation/components/organisms/reader_settings_sheet.dart';
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

  Future<void> pumpOpener(
    WidgetTester tester,
    List<Widget> Function(ReaderPreferences) sections, {
    ThemeData? theme,
  }) => tester.pumpApp(
    Provider<ReaderPreferencesService>.value(
      value: service,
      child: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                ReaderSettingsSheet.show(context, sections: sections),
            child: const Text('open'),
          ),
        ),
      ),
    ),
    theme: theme ?? AppTheme.lightTheme,
  );

  List<Widget> textSection(ReaderPreferences prefs) => [
    TextReaderSettingsSection(
      preferences: prefs.text,
      onChanged: (change) =>
          service.update((p) => p.copyWith(text: change(p.text))),
    ),
  ];

  testWidgets('ReaderSettingsSheet.show opens a titled sheet that follows '
      'the service', (tester) async {
    await pumpOpener(tester, (prefs) => [Text('section ${prefs.theme.name}')]);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Reading settings'), findsOneWidget);
    expect(find.text('section standard'), findsOneWidget);

    await service.update((p) => p.copyWith(theme: ReaderTheme.sepia));
    await tester.pumpAndSettle();

    expect(find.text('section sepia'), findsOneWidget);
  });

  testWidgets('sheet text is readable on Sépia under a dark app theme', (
    tester,
  ) async {
    await service.update((p) => p.copyWith(theme: ReaderTheme.sepia));
    await pumpOpener(tester, textSection, theme: AppTheme.darkTheme);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final title = tester.widget<Text>(find.text('Reading settings'));
    expect(title.style?.color, ReaderPalette.sepia.text);
    final rowTitle = tester.widget<Text>(find.text('Font'));
    expect(rowTitle.style?.color, ReaderPalette.sepia.text);
    final dropdown = tester.widget<Text>(find.text('Serif'));
    expect(
      DefaultTextStyle.of(tester.element(find.text('Serif'))).style.color ??
          dropdown.style?.color,
      ReaderPalette.sepia.text,
    );
  });

  testWidgets('Padrão subtitles stay readable on the Dracula sheet surface', (
    tester,
  ) async {
    await pumpOpener(tester, textSection, theme: AppTheme.draculaTheme);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final subtitle = tester.widget<Text>(find.text('Text family'));
    expect(subtitle.style?.color, draculaPalette.text.withAlpha(0xB3));
  });

  testWidgets('two stepper taps in one frame both apply', (tester) async {
    await pumpOpener(tester, textSection);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Increase font size'));
    await tester.tap(find.byTooltip('Increase font size'));
    await tester.pumpAndSettle();

    expect(service.current.text.fontSize, 21);
    expect(find.text('Font size (21px)'), findsOneWidget);
  });

  testWidgets('the shared theme picker updates the service', (tester) async {
    await pumpOpener(tester, (_) => const []);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cream'));
    await tester.pumpAndSettle();

    expect(service.current.theme, ReaderTheme.cream);
    expect(service.current.text, TextReaderPreferences.defaults);
  });
}
