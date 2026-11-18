import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/connectivity/connectivity_service.dart';
import 'package:gatuno/core/network/api_constants.dart';
import 'package:gatuno/core/network/dio_client.dart';
import 'package:gatuno/core/network/interceptors/auth_interceptor.dart';
import 'package:gatuno/features/authentication/data/data_sources/auth_local_data_source.dart';
import 'package:gatuno/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:gatuno/features/authentication/domain/use_cases/auth_service.dart';
import 'package:gatuno/features/authentication/domain/use_cases/token_manager.dart';
import 'package:mocktail/mocktail.dart';

// These tests run the real interceptor chain (Dio, AuthInterceptor,
// TokenManager, AuthRepositoryImpl) over a fake adapter. The unit tests in
// auth_interceptor_test.dart call onRequest directly, so they cannot see the
// deadlocks from #159, which come from how Dio schedules interceptors.

class MockDioClient extends Mock implements DioClient {}

class MockConnectivityService extends Mock implements ConnectivityService {}

class FakeAuthStorage extends Fake implements AuthStorage {
  FakeAuthStorage(this.token);

  String? token;
  int clears = 0;

  @override
  Future<String?> getToken() async => token;

  @override
  Future<void> saveToken(String value) async => token = value;

  @override
  Future<void> clearToken() async {
    clears++;
    token = null;
  }
}

typedef Route = FutureOr<ResponseBody> Function(RequestOptions options);

/// Answers requests by path and records every request it receives.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.routes);

  final Map<String, Route> routes;
  final List<RequestOptions> requests = [];

  List<String> get paths => requests.map((r) => r.path).toList();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final route = routes[options.path];
    if (route == null) return json(404, {'message': 'Not found'});
    return route(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody json(
  int status,
  Map<String, dynamic> body, {
  Map<String, List<String>>? headers,
}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
      ...?headers,
    },
  );
}

String jwt(Duration expiresIn) {
  final exp = DateTime.now().add(expiresIn).millisecondsSinceEpoch ~/ 1000;
  final payload = base64Url
      .encode(utf8.encode('{"exp": $exp, "sub": "user"}'))
      .replaceAll('=', '');
  return 'header.$payload.signature';
}

String? bearer(RequestOptions options) =>
    options.headers['Authorization']?.toString();

/// A test that would hang on a deadlock fails here instead of stalling CI.
const deadlockTimeout = Timeout(Duration(seconds: 5));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Dio dio;
  late FakeAuthStorage storage;
  late TokenManager tokenManager;
  late StreamController<void> reconnected;
  late ConnectivityService connectivity;

  setUp(() {
    reconnected = StreamController<void>.broadcast();
    addTearDown(reconnected.close);
    connectivity = MockConnectivityService();
    when(
      () => connectivity.onReconnected,
    ).thenAnswer((_) => reconnected.stream);
  });

  final expired = jwt(const Duration(hours: -1));
  final valid = jwt(const Duration(hours: 1));
  final fresh = jwt(const Duration(hours: 2));

  void wire(
    FakeAdapter adapter, {
    required String storedToken,
    Future<void> Function(Duration)? delay,
  }) {
    dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    final dioClient = MockDioClient();
    when(() => dioClient.dio).thenReturn(dio);

    storage = FakeAuthStorage(storedToken);
    tokenManager = TokenManager(AuthRepositoryImpl(dio), storage, delay: delay);
    setupAuthInterceptor(dioClient, tokenManager);
  }

  test(
    'an expired token at startup is refreshed and the request is sent with it',
    () async {
      final adapter = FakeAdapter({
        ApiConstants.authRefresh: (_) => json(200, {'accessToken': fresh}),
        ApiConstants.books: (o) => bearer(o) == 'Bearer $fresh'
            ? json(200, {'data': <dynamic>[]})
            : json(401, {'message': 'Unauthorized'}),
      });
      wire(adapter, storedToken: expired);

      final response = await dio.get<dynamic>(ApiConstants.books);

      expect(response.statusCode, 200);
      expect(adapter.paths, [ApiConstants.authRefresh, ApiConstants.books]);
      expect(storage.token, fresh);
    },
    timeout: deadlockTimeout,
  );

  test(
    'a retry that also gets a 401 reaches the caller instead of hanging',
    () async {
      final adapter = FakeAdapter({
        ApiConstants.authRefresh: (_) => json(200, {'accessToken': fresh}),
        ApiConstants.books: (_) => json(401, {'message': 'Unauthorized'}),
      });
      wire(adapter, storedToken: valid);

      await expectLater(
        dio.get<dynamic>(ApiConstants.books),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            401,
          ),
        ),
      );
      expect(adapter.paths, [
        ApiConstants.books,
        ApiConstants.authRefresh,
        ApiConstants.books,
      ]);
    },
    timeout: deadlockTimeout,
  );

  for (final code in const [
    'REFRESH_TOKEN_MISSING',
    'REFRESH_TOKEN_INVALID',
    'REFRESH_SESSION_NOT_FOUND',
    'REFRESH_TOKEN_REUSED',
    'REFRESH_USER_NOT_FOUND',
  ]) {
    test(
      'a refused refresh with 401 ($code) signs out locally without calling /auth/logout',
      () async {
        final adapter = FakeAdapter({
          ApiConstants.authRefresh: (_) => json(401, {
            'message': 'Access Denied. Invalid token.',
            'code': code,
          }),
          ApiConstants.logout: (_) => json(401, {'message': 'Unauthorized'}),
          // Guests can browse: the list answers without a token.
          ApiConstants.books: (o) => bearer(o) == null
              ? json(200, {'data': <dynamic>[]})
              : json(401, {'message': 'Unauthorized'}),
        });
        wire(adapter, storedToken: expired);

        final authService = AuthService(
          AuthRepositoryImpl(dio),
          tokenManager,
          connectivity,
        );
        addTearDown(authService.dispose);
        final request = dio.get<dynamic>(ApiConstants.books);

        await expectLater(
          authService.authStateStream,
          emitsThrough(AuthState.unauthenticated),
        );
        final response = await request;

        expect(response.statusCode, 200);
        expect(storage.token, isNull);
        expect(adapter.paths, isNot(contains(ApiConstants.logout)));
      },
      timeout: deadlockTimeout,
    );
  }
  for (final failure in <String, Route>{
    'no network': (o) => throw DioException.connectionError(
      requestOptions: o,
      reason: 'offline',
    ),
    'a timeout': (o) => throw DioException.connectionTimeout(
      timeout: const Duration(seconds: 5),
      requestOptions: o,
    ),
    'a 403 CSRF_TOKEN_INVALID': (_) => json(403, {
      'message': 'Invalid CSRF token',
      'code': 'CSRF_TOKEN_INVALID',
    }),
    'a 429': (_) => json(429, {'message': 'Too Many Requests'}),
    'a 500': (_) => json(500, {'message': 'Internal server error'}),
  }.entries) {
    test('a refresh that fails with ${failure.key} keeps the user signed in '
        'and refreshes again on reconnect', () async {
      var refreshes = 0;
      final adapter = FakeAdapter({
        ApiConstants.authRefresh: (o) {
          refreshes++;
          return refreshes == 1
              ? failure.value(o)
              : json(200, {'accessToken': fresh});
        },
      });
      wire(adapter, storedToken: expired);

      final authService = AuthService(
        AuthRepositoryImpl(dio),
        tokenManager,
        connectivity,
      );
      addTearDown(authService.dispose);

      await expectLater(
        authService.authStateStream,
        emitsThrough(AuthState.authenticated),
      );
      expect(storage.token, expired);
      expect(storage.clears, 0);
      expect(refreshes, 1);

      reconnected.add(null);
      await pumpEventQueue();

      expect(refreshes, 2);
      expect(storage.token, fresh);
      expect(authService.authenticated, isTrue);
      expect(adapter.paths, isNot(contains(ApiConstants.logout)));
    }, timeout: deadlockTimeout);
  }

  test(
    'a 409 REFRESH_IN_PROGRESS waits Retry-After and retries once inside the single-flight future',
    () async {
      var refreshes = 0;
      final recordedDelays = <Duration>[];
      final adapter = FakeAdapter({
        ApiConstants.authRefresh: (_) {
          refreshes++;
          if (refreshes == 1) {
            return json(
              409,
              {
                'message': 'Refresh already in progress',
                'code': 'REFRESH_IN_PROGRESS',
              },
              headers: {
                'Retry-After': ['2'],
              },
            );
          }
          return json(200, {'accessToken': fresh});
        },
        ApiConstants.books: (o) => bearer(o) == 'Bearer $fresh'
            ? json(200, {'data': <dynamic>[]})
            : json(401, {'message': 'Unauthorized'}),
      });
      wire(
        adapter,
        storedToken: expired,
        delay: (d) async => recordedDelays.add(d),
      );

      final responses = await Future.wait([
        dio.get<dynamic>(ApiConstants.books),
        dio.get<dynamic>(ApiConstants.books),
      ]);

      expect(responses.every((r) => r.statusCode == 200), isTrue);
      expect(refreshes, 2);
      expect(recordedDelays, [const Duration(seconds: 2)]);
      expect(storage.token, fresh);
      expect(storage.clears, 0);
    },
    timeout: deadlockTimeout,
  );

  test(
    'a 409 REFRESH_IN_PROGRESS whose retry also gets 409 keeps the user signed in',
    () async {
      var refreshes = 0;
      final recordedDelays = <Duration>[];
      final adapter = FakeAdapter({
        ApiConstants.authRefresh: (_) {
          refreshes++;
          return json(409, {
            'message': 'Refresh already in progress',
            'code': 'REFRESH_IN_PROGRESS',
          });
        },
      });
      wire(
        adapter,
        storedToken: expired,
        delay: (d) async => recordedDelays.add(d),
      );

      await expectLater(tokenManager.performTokenRefresh(), throwsException);

      expect(refreshes, 2);
      expect(recordedDelays, [const Duration(seconds: 1)]);
      expect(storage.token, expired);
      expect(storage.clears, 0);
    },
    timeout: deadlockTimeout,
  );

  test(
    'a 409 REFRESH_IN_PROGRESS whose retry gets 401 signs out locally',
    () async {
      var refreshes = 0;
      final adapter = FakeAdapter({
        ApiConstants.authRefresh: (_) {
          refreshes++;
          if (refreshes == 1) {
            return json(409, {
              'message': 'Refresh already in progress',
              'code': 'REFRESH_IN_PROGRESS',
            });
          }
          return json(401, {
            'message': 'Invalid refresh token',
            'code': 'REFRESH_TOKEN_INVALID',
          });
        },
      });
      wire(adapter, storedToken: expired, delay: (_) async {});

      await expectLater(tokenManager.performTokenRefresh(), throwsException);

      expect(refreshes, 2);
      expect(storage.token, isNull);
      expect(storage.clears, 1);
    },
    timeout: deadlockTimeout,
  );

  test(
    'scheduled refresh reschedules with exponential backoff up to 5m and resets on saveToken/pauseRefresh',
    () {
      fakeAsync((async) {
        var refreshes = 0;
        final adapter = FakeAdapter({
          ApiConstants.authRefresh: (_) {
            refreshes++;
            if (refreshes == 7) {
              // Return a ~65s token so saveToken schedules the next proactive
              // refresh in ~5s (which will fail as #8).
              return json(200, {
                'accessToken': jwt(const Duration(seconds: 65)),
              });
            }
            return json(500, {'message': 'Internal server error'});
          },
        });
        wire(adapter, storedToken: expired);

        tokenManager.initialize();
        async.elapse(Duration.zero);
        expect(refreshes, 1);

        // 1st retry at 30s
        async.elapse(const Duration(seconds: 29));
        expect(refreshes, 1);
        async.elapse(const Duration(seconds: 1));
        expect(refreshes, 2);

        // 2nd retry at 60s
        async.elapse(const Duration(seconds: 59));
        expect(refreshes, 2);
        async.elapse(const Duration(seconds: 1));
        expect(refreshes, 3);

        // 3rd retry at 120s
        async.elapse(const Duration(seconds: 119));
        expect(refreshes, 3);
        async.elapse(const Duration(seconds: 1));
        expect(refreshes, 4);

        // 4th retry at 240s
        async.elapse(const Duration(seconds: 239));
        expect(refreshes, 4);
        async.elapse(const Duration(seconds: 1));
        expect(refreshes, 5);

        // 5th retry capped at 5m (300s)
        async.elapse(const Duration(seconds: 299));
        expect(refreshes, 5);
        async.elapse(const Duration(seconds: 1));
        expect(refreshes, 6);

        // Succeed on 300s retry (#7) -> saveToken resets backoff to 30s and
        // schedules proactive refresh in ~5s.
        async.elapse(const Duration(seconds: 300));
        expect(refreshes, 7);

        // Proactive refresh fires within 5s (#8) and fails.
        async.elapse(const Duration(seconds: 5));
        expect(refreshes, 8);

        // Next retry after saveToken reset must fire at 30s (not 300s)
        async.elapse(const Duration(seconds: 29));
        expect(refreshes, 8);
        async.elapse(const Duration(seconds: 1));
        expect(refreshes, 9);

        // Now next backoff would be 60s; pauseRefresh cancels it and resets to 30s
        tokenManager.pauseRefresh();
        async.elapse(const Duration(minutes: 10));
        expect(refreshes, 9);

        tokenManager.resumeRefresh();
        async.elapse(const Duration(seconds: 5));
        expect(refreshes, 10);

        async.elapse(const Duration(seconds: 29));
        expect(refreshes, 10);
        async.elapse(const Duration(seconds: 1));
        expect(refreshes, 11);
      });
    },
  );

  test(
    'scheduled refresh stops rescheduling after 401 dead-session sign-out',
    () {
      fakeAsync((async) {
        var refreshes = 0;
        final adapter = FakeAdapter({
          ApiConstants.authRefresh: (_) {
            refreshes++;
            return json(401, {
              'message': 'Token reused',
              'code': 'REFRESH_TOKEN_REUSED',
            });
          },
        });
        wire(adapter, storedToken: expired);

        tokenManager.initialize();
        async.elapse(Duration.zero);
        expect(refreshes, 1);
        expect(storage.token, isNull);

        async.elapse(const Duration(minutes: 10));
        expect(refreshes, 1);
      });
    },
  );
}
