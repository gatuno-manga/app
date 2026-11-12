import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/theme.dart';
import 'package:gatuno/features/reading/data/data_sources/reader_preferences_storage.dart';
import 'package:gatuno/features/reading/domain/entities/reader_preferences.dart';
import 'package:gatuno/features/reading/domain/use_cases/reader_preferences_service.dart';
import 'package:gatuno/features/reading/presentation/components/organisms/reader_preferences_controls.dart';
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

  Future<void> pump(
    WidgetTester tester, {
    String? themeTitle,
    TextScaler textScaler = TextScaler.noScaling,
  }) => tester.pumpApp(
    MediaQuery(
      data: MediaQueryData(textScaler: textScaler),
      child: Provider<ReaderPreferencesService>.value(
        value: service,
        child: Scaffold(
          body: SingleChildScrollView(
            child: ReaderPreferencesControls(
              sections: TextReaderSettingsSection.sectionsFor(service),
              themeTitle: themeTitle,
            ),
          ),
        ),
      ),
    ),
    theme: AppTheme.lightTheme,
  );

  testWidgets('shows the theme picker and the given sections', (tester) async {
    await pump(tester);

    expect(find.text('Sepia'), findsOneWidget);
    expect(find.text('Font'), findsOneWidget);
  });

  testWidgets('picking a theme updates the service', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Sepia'));
    await tester.pump();

    expect(service.current.theme, ReaderTheme.sepia);
  });

  testWidgets('text rows update the service text preferences', (tester) async {
    await pump(tester);

    await tester.tap(find.byTooltip('Increase font size'));
    await tester.pump();

    expect(service.current.text.fontSize, 20);
    expect(service.current.theme, ReaderTheme.standard);
  });

  testWidgets('follows changes made elsewhere', (tester) async {
    await pump(tester);

    await service.update((p) => p.copyWith(theme: ReaderTheme.cream));
    await tester.pump();

    expect(find.text('Font size (19px)'), findsOneWidget);
    await service.update((p) => p.copyWith(text: p.text.stepFontSize(1)));
    await tester.pump();
    expect(find.text('Font size (20px)'), findsOneWidget);
  });

  testWidgets('shows the theme caption only when given', (tester) async {
    await pump(tester);
    expect(find.text('Reading theme'), findsNothing);

    await pump(tester, themeTitle: 'Reading theme');
    expect(find.text('Reading theme'), findsOneWidget);
  });

  testWidgets('lays out at 2x text scale without overflow', (tester) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pump(tester, textScaler: const TextScaler.linear(2));

    expect(tester.takeException(), isNull);
  });
}
