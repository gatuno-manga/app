import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
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

ResponseBody json(int status, Map<String, dynamic> body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
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

  void wire(FakeAdapter adapter, {required String storedToken}) {
    dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    final dioClient = MockDioClient();
    when(() => dioClient.dio).thenReturn(dio);

    storage = FakeAuthStorage(storedToken);
    tokenManager = TokenManager(AuthRepositoryImpl(dio), storage);
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

  test(
    'a refused refresh signs out locally without calling /auth/logout',
    () async {
      final adapter = FakeAdapter({
        ApiConstants.authRefresh: (_) =>
            json(401, {'message': 'Access Denied. Invalid token.'}),
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
  for (final failure in <String, Route>{
    'no network': (o) => throw DioException.connectionError(
      requestOptions: o,
      reason: 'offline',
    ),
    'a timeout': (o) => throw DioException.connectionTimeout(
      timeout: const Duration(seconds: 5),
      requestOptions: o,
    ),
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
}
