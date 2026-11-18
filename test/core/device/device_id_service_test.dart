import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/device/device_id_service.dart';
import 'package:gatuno/core/storage/background_readable_storage.dart';
import 'package:mocktail/mocktail.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  final uuidRegex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[45][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );

  late MockSecureStorage storage;
  late MockSecureStorage legacy;

  setUp(() {
    storage = MockSecureStorage();
    legacy = MockSecureStorage();
    when(() => legacy.readAll()).thenAnswer((_) async => {});
    when(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});
  });

  BackgroundReadableStorage createStore() => BackgroundReadableStorage(
    owns: (key) => key == 'device_id',
    storage: storage,
    legacy: legacy,
    isIOS: false,
  );

  group('DeviceIdService', () {
    test(
      'returns persisted ID without calling platform provider or rewriting',
      () async {
        const persistedId = '11111111-2222-4333-8444-555555555555';
        when(
          () => storage.read(key: 'device_id'),
        ).thenAnswer((_) async => persistedId);
        var platformCalled = false;

        final service = DeviceIdService(
          store: createStore(),
          getPlatformId: () async {
            platformCalled = true;
            return 'android-id-1';
          },
        );

        final first = await service.getDeviceId();
        final second = await service.getDeviceId();

        expect(first, persistedId);
        expect(second, persistedId);
        expect(platformCalled, isFalse);
        verify(() => storage.read(key: 'device_id')).called(1);
        verifyNever(
          () => storage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        );
      },
    );

    test(
      'derives deterministic UUID from platform ID and persists it',
      () async {
        when(
          () => storage.read(key: 'device_id'),
        ).thenAnswer((_) async => null);

        final serviceA = DeviceIdService(
          store: createStore(),
          getPlatformId: () async => '9774d56d682e549c',
        );
        final serviceB = DeviceIdService(
          store: createStore(),
          getPlatformId: () async => '9774d56d682e549c',
        );
        final serviceOther = DeviceIdService(
          store: createStore(),
          getPlatformId: () async => 'aaaaaaaaaaaaaaaa',
        );

        final idA = await serviceA.getDeviceId();
        final idB = await serviceB.getDeviceId();
        final idOther = await serviceOther.getDeviceId();

        expect(idA, matches(uuidRegex));
        expect(idA, idB);
        expect(idA, isNot(idOther));
        verify(() => storage.write(key: 'device_id', value: idA)).called(2);
        verify(() => storage.write(key: 'device_id', value: idOther)).called(1);
      },
    );

    test(
      'falls back to random UUID v4 when platform ID is null or throws',
      () async {
        when(
          () => storage.read(key: 'device_id'),
        ).thenAnswer((_) async => null);

        final service = DeviceIdService(
          store: createStore(),
          getPlatformId: () async => throw StateError('unavailable'),
          random: Random(42),
        );

        final id = await service.getDeviceId();

        expect(id, matches(uuidRegex));
        expect(id[14], '4');
        verify(() => storage.write(key: 'device_id', value: id)).called(1);
      },
    );

    test('deduplicates concurrent getDeviceId calls', () async {
      when(() => storage.read(key: 'device_id')).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return null;
      });
      var platformCalls = 0;

      final service = DeviceIdService(
        store: createStore(),
        getPlatformId: () async {
          platformCalls++;
          return null;
        },
        random: Random(7),
      );

      final results = await Future.wait([
        service.getDeviceId(),
        service.getDeviceId(),
        service.getDeviceId(),
      ]);

      expect(results.toSet(), hasLength(1));
      expect(platformCalls, 1);
      verify(
        () => storage.write(key: 'device_id', value: results.first),
      ).called(1);
    });
  });
}
