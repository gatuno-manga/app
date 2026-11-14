import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/connectivity/connectivity_service.dart';
import 'package:gatuno/core/network/interceptors/connectivity_interceptor.dart';
import 'package:mocktail/mocktail.dart';

class MockConnectivityService extends Mock implements ConnectivityService {}

class MockResponseInterceptorHandler extends Mock
    implements ResponseInterceptorHandler {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

/// Answers every request with a cacheable JSON body and counts the calls.
class _CountingAdapter implements HttpClientAdapter {
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    return ResponseBody.fromString(
      jsonEncode({'ok': true}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        HttpHeaders.cacheControlHeader: ['max-age=3600'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  const base = 'https://server.example';
  late MockConnectivityService connectivity;
  late ConnectivityInterceptor interceptor;
  late MockErrorInterceptorHandler errorHandler;
  final request = RequestOptions(baseUrl: base, path: '/books');

  setUpAll(() {
    registerFallbackValue(DioException(requestOptions: RequestOptions()));
    registerFallbackValue(Response<dynamic>(requestOptions: RequestOptions()));
  });

  setUp(() {
    connectivity = MockConnectivityService();
    when(() => connectivity.checkNow()).thenAnswer((_) async {});
    interceptor = ConnectivityInterceptor(connectivity, baseUrl: () => base);
    errorHandler = MockErrorInterceptorHandler();
  });

  DioException error(
    DioExceptionType type, {
    Object? cause,
    int? status,
    RequestOptions? options,
  }) {
    final req = options ?? request;
    return DioException(
      requestOptions: req,
      type: type,
      error: cause,
      response: status == null
          ? null
          : Response<dynamic>(requestOptions: req, statusCode: status),
    );
  }

  test('a network response from the server reports it reachable', () {
    final handler = MockResponseInterceptorHandler();
    final response = Response<dynamic>(requestOptions: request);

    interceptor.onResponse(response, handler);

    verify(() => connectivity.reportReachable()).called(1);
    verify(() => handler.next(response)).called(1);
  });

  test('a response served from the HTTP cache is ignored', () {
    final response = Response<dynamic>(
      requestOptions: request,
      extra: {extraFromNetworkKey: false},
    );

    interceptor.onResponse(response, MockResponseInterceptorHandler());

    verifyNever(() => connectivity.reportReachable());
  });

  test('the probe\'s own request is ignored', () {
    final probe = RequestOptions(
      baseUrl: base,
      path: '/health/liveness',
      extra: {ConnectivityInterceptor.probeExtraKey: true},
    );

    interceptor.onError(
      error(DioExceptionType.badResponse, status: 500, options: probe),
      errorHandler,
    );
    interceptor.onResponse(
      Response<dynamic>(requestOptions: probe),
      MockResponseInterceptorHandler(),
    );

    verifyNever(() => connectivity.reportReachable());
  });

  test('requests to another host are ignored', () {
    final other = RequestOptions(path: 'https://cdn.other/x.webp');

    interceptor.onResponse(
      Response<dynamic>(requestOptions: other),
      MockResponseInterceptorHandler(),
    );
    interceptor.onError(
      error(DioExceptionType.connectionError, options: other),
      errorHandler,
    );

    verifyNever(() => connectivity.reportReachable());
    verifyNever(() => connectivity.reportUnreachable());
  });

  for (final type in [
    DioExceptionType.connectionError,
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
  ]) {
    test('$type reports the server unreachable', () {
      final err = error(type);
      interceptor.onError(err, errorHandler);

      verify(() => connectivity.reportUnreachable()).called(1);
      verify(() => errorHandler.next(err)).called(1);
    });
  }

  test('a socket error reports the server unreachable', () {
    interceptor.onError(
      error(DioExceptionType.unknown, cause: const SocketException('down')),
      errorHandler,
    );

    verify(() => connectivity.reportUnreachable()).called(1);
  });

  test('an error status means the server answered', () {
    interceptor.onError(
      error(DioExceptionType.badResponse, status: 500),
      errorHandler,
    );

    verify(() => connectivity.reportReachable()).called(1);
    verifyNever(() => connectivity.reportUnreachable());
  });

  for (final status in [502, 503, 504]) {
    test('a gateway error ($status) asks the probe instead', () {
      interceptor.onError(
        error(DioExceptionType.badResponse, status: status),
        errorHandler,
      );

      verify(() => connectivity.checkNow()).called(1);
      verifyNever(() => connectivity.reportReachable());
    });
  }

  test('a certificate error leaves the status alone', () {
    interceptor.onError(error(DioExceptionType.badCertificate), errorHandler);

    verifyNever(() => connectivity.reportReachable());
    verifyNever(() => connectivity.reportUnreachable());
  });

  test('in the real chain, a fresh HTTP cache hit does not count', () async {
    final adapter = _CountingAdapter();
    final dio = Dio(BaseOptions(baseUrl: base))..httpClientAdapter = adapter;
    dio.interceptors
      ..add(DioCacheInterceptor(options: CacheOptions(store: MemCacheStore())))
      ..insert(0, interceptor);

    await dio.get<dynamic>('/books');
    await dio.get<dynamic>('/books');

    expect(adapter.calls, 1);
    verify(() => connectivity.reportReachable()).called(1);
  });
}
