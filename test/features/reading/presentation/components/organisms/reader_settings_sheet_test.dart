import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/reading/data/data_sources/reader_preferences_storage.dart';
import 'package:gatuno/features/reading/domain/entities/reader_preferences.dart';
import 'package:gatuno/features/reading/domain/use_cases/reader_preferences_service.dart';
import 'package:gatuno/features/reading/presentation/components/organisms/reader_settings_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  late ReaderPreferencesService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = ReaderPreferencesService(ReaderPreferencesStorage());
  });

  tearDown(() => service.dispose());

  testWidgets('ReaderSettingsSheet.show opens a titled sheet that follows '
      'the service', (tester) async {
    await tester.pumpApp(
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => ReaderSettingsSheet.show(
              context,
              service: service,
              sections: (prefs) => [Text('section ${prefs.theme.name}')],
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Reading settings'), findsOneWidget);
    expect(find.text('section standard'), findsOneWidget);

    await service.update(
      ReaderPreferences.defaults.copyWith(theme: ReaderTheme.sepia),
    );
    await tester.pumpAndSettle();

    expect(find.text('section sepia'), findsOneWidget);
  });

  testWidgets('the shared theme picker updates the service', (tester) async {
    await tester.pumpApp(
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => ReaderSettingsSheet.show(
              context,
              service: service,
              sections: (_) => const [],
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cream'));
    await tester.pumpAndSettle();

    expect(service.current.theme, ReaderTheme.cream);
    expect(service.current.text, TextReaderPreferences.defaults);
  });
}
