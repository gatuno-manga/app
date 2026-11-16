import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/storage/background_readable_storage.dart';
import 'package:mocktail/mocktail.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockSecureStorage storage;
  late MockSecureStorage legacy;

  setUp(() {
    storage = MockSecureStorage();
    legacy = MockSecureStorage();
    when(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});
    when(() => legacy.delete(key: any(named: 'key'))).thenAnswer((_) async {});
  });

  BackgroundReadableStorage store({required bool isIOS}) =>
      BackgroundReadableStorage(
        owns: (key) => key.startsWith('cookie_'),
        storage: storage,
        legacy: legacy,
        isIOS: isIOS,
      );

  test('uses first_unlock on iOS', () {
    expect(
      BackgroundReadableStorage.iOSOptions.accessibility,
      KeychainAccessibility.first_unlock,
    );
  });

  test('moves its own items to the new accessibility, once', () async {
    when(() => legacy.readAll()).thenAnswer(
      (_) async => {'cookie_.index': 'a', 'cookie_host': 'b', 'pin': 'c'},
    );
    final s = store(isIOS: true);

    await s.migrate();
    await s.migrate();

    verify(() => legacy.readAll()).called(1);
    for (final MapEntry(:key, :value) in {
      'cookie_.index': 'a',
      'cookie_host': 'b',
    }.entries) {
      verifyInOrder([
        () => legacy.delete(key: key),
        () => storage.write(key: key, value: value),
      ]);
    }
    verifyNever(() => legacy.delete(key: 'pin'));
  });

  test('a failed write puts the old item back', () async {
    when(() => legacy.readAll()).thenAnswer((_) async => {'cookie_host': 'b'});
    when(
      () => legacy.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => storage.write(key: 'cookie_host', value: 'b'),
    ).thenThrow(Exception('keychain'));

    await store(isIOS: true).migrate();

    verifyInOrder([
      () => legacy.delete(key: 'cookie_host'),
      () => storage.write(key: 'cookie_host', value: 'b'),
      () => legacy.write(key: 'cookie_host', value: 'b'),
    ]);
  });

  test('does nothing on Android', () async {
    await store(isIOS: false).migrate();

    verifyNever(() => legacy.readAll());
  });

  test('a failure is tried again on the next call', () async {
    var calls = 0;
    when(() => legacy.readAll()).thenAnswer((_) async {
      if (calls++ == 0) throw Exception('locked');
      return {'cookie_host': 'b'};
    });
    final s = store(isIOS: true);

    await s.migrate();
    await s.migrate();

    verify(() => storage.write(key: 'cookie_host', value: 'b')).called(1);
  });
}
