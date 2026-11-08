import 'dart:async';

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

    test(
      'update applies the change to the current value and persists it',
      () async {
        when(() => storage.write(any())).thenAnswer((_) async {});

        await service.update((p) => p.copyWith(theme: ReaderTheme.sepia));

        expect(service.current, stored);
        verify(() => storage.write(stored)).called(1);
      },
    );

    test('update emits before the write completes', () async {
      final writeStarted = Completer<void>();
      final finishWrite = Completer<void>();
      when(() => storage.write(any())).thenAnswer((_) {
        writeStarted.complete();
        return finishWrite.future;
      });

      final pending = service.update(
        (p) => p.copyWith(theme: ReaderTheme.sepia),
      );
      await writeStarted.future;

      expect(service.current, stored);
      finishWrite.complete();
      await pending;
    });

    test('two updates without awaiting both apply', () async {
      when(() => storage.write(any())).thenAnswer((_) async {});

      final first = service.update(
        (p) => p.copyWith(text: p.text.stepFontSize(1)),
      );
      final second = service.update(
        (p) => p.copyWith(text: p.text.stepFontSize(1)),
      );
      await Future.wait([first, second]);

      expect(service.current.text.fontSize, 21);
    });

    test('a failed write reverts to the previous value', () async {
      when(() => storage.write(any())).thenThrow(Exception('disk full'));

      await service.update((p) => p.copyWith(theme: ReaderTheme.sepia));

      expect(service.current, ReaderPreferences.defaults);
    });

    test('init retries after a failed read', () async {
      var calls = 0;
      when(() => storage.read()).thenAnswer((_) async {
        calls++;
        if (calls == 1) throw Exception('disk');
        return stored;
      });

      await service.init();
      expect(service.current, ReaderPreferences.defaults);
      await service.init();
      expect(service.current, stored);
    });
  });
}
