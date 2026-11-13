import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/connectivity/connectivity_service.dart';
import 'package:gatuno/core/network/interceptors/connectivity_interceptor.dart';
import 'package:mocktail/mocktail.dart';

class MockConnectivityService extends Mock implements ConnectivityService {}

class MockResponseInterceptorHandler extends Mock
    implements ResponseInterceptorHandler {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

void main() {
  late MockConnectivityService connectivity;
  late ConnectivityInterceptor interceptor;
  late MockErrorInterceptorHandler errorHandler;
  final request = RequestOptions(path: '/books');

  setUpAll(() {
    registerFallbackValue(DioException(requestOptions: RequestOptions()));
    registerFallbackValue(Response<dynamic>(requestOptions: RequestOptions()));
  });

  setUp(() {
    connectivity = MockConnectivityService();
    interceptor = ConnectivityInterceptor(connectivity);
    errorHandler = MockErrorInterceptorHandler();
  });

  DioException error(DioExceptionType type, {Object? cause, int? status}) =>
      DioException(
        requestOptions: request,
        type: type,
        error: cause,
        response: status == null
            ? null
            : Response<dynamic>(requestOptions: request, statusCode: status),
      );

  test('a response reports the server reachable', () {
    final handler = MockResponseInterceptorHandler();
    final response = Response<dynamic>(requestOptions: request);

    interceptor.onResponse(response, handler);

    verify(() => connectivity.reportReachable()).called(1);
    verify(() => handler.next(response)).called(1);
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

  test('a certificate error leaves the status alone', () {
    interceptor.onError(error(DioExceptionType.badCertificate), errorHandler);

    verifyNever(() => connectivity.reportReachable());
    verifyNever(() => connectivity.reportUnreachable());
  });
}
