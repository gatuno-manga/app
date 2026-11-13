import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/connectivity/connectivity_service.dart';
import 'package:gatuno/core/network/exceptions.dart';
import 'package:gatuno/core/offline/read_through.dart';
import 'package:mocktail/mocktail.dart';

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late MockConnectivityService connectivity;
  late ReadThrough readThrough;
  late List<String> saved;
  late int fetches;

  setUp(() {
    connectivity = MockConnectivityService();
    readThrough = ReadThrough(connectivity);
    saved = [];
    fetches = 0;
  });

  Future<String> run({
    required Future<String> Function() fetch,
    String? cached,
    Future<void> Function(String)? save,
  }) => readThrough<String>(
    fetch: () {
      fetches++;
      return fetch();
    },
    save: save ?? (value) async => saved.add(value),
    load: () async => cached,
  );

  group('online', () {
    setUp(() {
      when(() => connectivity.status).thenReturn(ConnectivityStatus.online);
    });

    test('fetches, saves and returns the network value', () async {
      final result = await run(fetch: () async => 'net', cached: 'old');

      expect(result, 'net');
      expect(saved, ['net']);
    });

    test('a failed save does not fail the call', () async {
      final result = await run(
        fetch: () async => 'net',
        save: (_) async => throw StateError('disk full'),
      );

      expect(result, 'net');
    });

    test('an unreachable server falls back to the cache', () async {
      final result = await run(
        fetch: () async => throw NetworkException(),
        cached: 'old',
      );

      expect(result, 'old');
      expect(saved, isEmpty);
    });

    test('an unreachable server with nothing cached throws offline', () {
      expect(
        run(fetch: () async => throw NetworkException()),
        throwsA(isA<OfflineException>()),
      );
    });

    test('a server error propagates and never falls back', () {
      expect(
        run(
          fetch: () async => throw ServerException(statusCode: 500),
          cached: 'old',
        ),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('offline', () {
    setUp(() {
      when(() => connectivity.status).thenReturn(ConnectivityStatus.offline);
    });

    test('serves the cache without touching the network', () async {
      final result = await run(fetch: () async => 'net', cached: 'old');

      expect(result, 'old');
      expect(fetches, 0);
    });

    test('a cache miss throws OfflineException', () {
      expect(run(fetch: () async => 'net'), throwsA(isA<OfflineException>()));
    });
  });

  test(
    'the transition: offline serves the cache, online fetches again',
    () async {
      var status = ConnectivityStatus.offline;
      when(() => connectivity.status).thenAnswer((_) => status);

      expect(await run(fetch: () async => 'net', cached: 'old'), 'old');
      status = ConnectivityStatus.online;
      expect(await run(fetch: () async => 'net', cached: 'old'), 'net');
      expect(fetches, 1);
    },
  );
}
