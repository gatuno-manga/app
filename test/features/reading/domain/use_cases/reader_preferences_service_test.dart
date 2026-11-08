import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/reading/data/data_sources/reader_preferences_storage.dart';
import 'package:gatuno/features/reading/domain/entities/reader_preferences.dart';
import 'package:gatuno/features/reading/domain/use_cases/reader_preferences_service.dart';
import 'package:mocktail/mocktail.dart';

class MockReaderPreferencesStorage extends Mock
    implements ReaderPreferencesStorage {}

void main() {
  late MockReaderPreferencesStorage storage;
  late ReaderPreferencesService service;

  const stored = ReaderPreferences(
    theme: ReaderTheme.sepia,
    text: TextReaderPreferences.defaults,
  );

  setUpAll(() => registerFallbackValue(ReaderPreferences.defaults));

  setUp(() {
    storage = MockReaderPreferencesStorage();
    service = ReaderPreferencesService(storage);
  });

  tearDown(() => service.dispose());

  group('ReaderPreferencesService', () {
    test('starts with defaults before init', () {
      expect(service.current, ReaderPreferences.defaults);
    });

    test('init loads the stored preferences once', () async {
      when(() => storage.read()).thenAnswer((_) async => stored);

      await service.init();
      await service.init();

      expect(service.current, stored);
      verify(() => storage.read()).called(1);
    });

    test('init keeps defaults when the read fails', () async {
      when(() => storage.read()).thenThrow(Exception('disk'));

      await service.init();

      expect(service.current, ReaderPreferences.defaults);
    });

    test('update writes, emits and returns true', () async {
      when(() => storage.write(any())).thenAnswer((_) async {});

      final emitted = expectLater(service.stream, emitsThrough(stored));
      final ok = await service.update(stored);

      expect(ok, isTrue);
      expect(service.current, stored);
      verify(() => storage.write(stored)).called(1);
      await emitted;
    });

    test('a failed write keeps the previous value and returns false', () async {
      when(() => storage.write(any())).thenThrow(Exception('disk full'));

      final ok = await service.update(stored);

      expect(ok, isFalse);
      expect(service.current, ReaderPreferences.defaults);
    });
  });
}
