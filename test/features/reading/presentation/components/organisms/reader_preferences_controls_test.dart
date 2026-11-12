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

  Future<void> pump(WidgetTester tester) => tester.pumpApp(
    Provider<ReaderPreferencesService>.value(
      value: service,
      child: Scaffold(
        body: SingleChildScrollView(
          child: ReaderPreferencesControls(
            preferences: service.current,
            sections: TextReaderSettingsSection.sectionsFor(service),
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
}
