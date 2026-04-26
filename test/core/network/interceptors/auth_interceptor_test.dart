import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gatuno/core/network/dio_client.dart';
import 'package:gatuno/core/network/interceptors/auth_interceptor.dart';
import 'package:gatuno/core/network/token_provider.dart';

class MockDioClient extends Mock implements DioClient {}

class MockTokenProvider extends Mock implements TokenProvider {}

class MockDio extends Mock implements Dio {}

class MockInterceptors extends Mock implements Interceptors {}

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

class FakeRequestOptions extends Fake implements RequestOptions {}

class FakeInterceptor extends Fake implements Interceptor {}

class FakeResponse extends Fake implements Response<dynamic> {}

void main() {
  late DioClient dioClient;
  late TokenProvider tokenProvider;
  late Dio dio;
  late Interceptors interceptors;
  late MockRequestInterceptorHandler requestHandler;
  late MockErrorInterceptorHandler errorHandler;
  const testBaseUrl = 'https://api.gatuno.com/api';

  setUpAll(() {
    registerFallbackValue(FakeRequestOptions());
    registerFallbackValue(FakeInterceptor());
    registerFallbackValue(FakeResponse());
    registerFallbackValue(
      DioException(requestOptions: RequestOptions(path: '/')),
    );
  });

  setUp(() {
    dioClient = MockDioClient();
    tokenProvider = MockTokenProvider();
    dio = MockDio();
    interceptors = MockInterceptors();
    requestHandler = MockRequestInterceptorHandler();
    errorHandler = MockErrorInterceptorHandler();

    when(() => dioClient.dio).thenReturn(dio);
    when(() => dio.interceptors).thenReturn(interceptors);
  });

  AuthInterceptor getInterceptor() {
    return AuthInterceptor(dioClient: dioClient, tokenProvider: tokenProvider);
  }

  group('onRequest', () {
    test('should NOT add Authorization header when token is null', () async {
      final options = RequestOptions(path: '/test', baseUrl: testBaseUrl);
      when(() => tokenProvider.getValidToken()).thenAnswer((_) async => null);
      when(() => requestHandler.next(any())).thenAnswer((_) {});

      getInterceptor().onRequest(options, requestHandler);

      await Future<void>.delayed(Duration.zero);
      expect(options.headers['Authorization'], isNull);
    });

    test('should add Authorization header when token is valid', () async {
      final options = RequestOptions(path: '/test', baseUrl: testBaseUrl);
      const token = 'valid_token';

      when(() => tokenProvider.getValidToken()).thenAnswer((_) async => token);
      when(() => requestHandler.next(any())).thenAnswer((_) {});

      getInterceptor().onRequest(options, requestHandler);

      await Future<void>.delayed(Duration.zero);
      expect(options.headers['Authorization'], 'Bearer $token');
      verify(() => tokenProvider.getValidToken()).called(1);
    });

    test('should NOT add Authorization header for external URLs', () async {
      final options = RequestOptions(
        path: 'https://other-api.com/data',
        baseUrl: testBaseUrl,
      );
      when(() => requestHandler.next(any())).thenAnswer((_) {});

      getInterceptor().onRequest(options, requestHandler);

      await Future<void>.delayed(Duration.zero);
      expect(options.headers['Authorization'], isNull);
      verifyNever(() => tokenProvider.getValidToken());
    });
  });

  group('onError', () {
    test(
      'should retry request if token was refreshed by another request',
      () async {
        final options = RequestOptions(
          path: '/test',
          baseUrl: testBaseUrl,
          headers: {'Authorization': 'Bearer old_token'},
        );
        final error = DioException(
          requestOptions: options,
          response: Response<dynamic>(requestOptions: options, statusCode: 401),
        );

        // currentToken (refreshed by A) is different from requestToken (old_token)
        when(
          () => tokenProvider.getValidToken(),
        ).thenAnswer((_) async => 'new_token');

        final response = Response<dynamic>(
          requestOptions: options,
          statusCode: 200,
        );
        when(() => dio.fetch<dynamic>(any())).thenAnswer((_) async => response);
        when(() => errorHandler.resolve(any())).thenAnswer((_) {});

        getInterceptor().onError(error, errorHandler);

        await Future<void>.delayed(Duration.zero);
        verify(() => dio.fetch<dynamic>(options)).called(1);
        verify(() => errorHandler.resolve(response)).called(1);
        // Should NOT call force refresh
        verifyNever(() => tokenProvider.getValidToken(forceRefresh: true));
      },
    );

    test(
      'should perform force refresh and retry if token is the same',
      () async {
        final options = RequestOptions(
          path: '/test',
          baseUrl: testBaseUrl,
          headers: {'Authorization': 'Bearer old_token'},
        );
        final error = DioException(
          requestOptions: options,
          response: Response<dynamic>(requestOptions: options, statusCode: 401),
        );

        // currentToken is still old_token
        when(
          () => tokenProvider.getValidToken(),
        ).thenAnswer((_) async => 'old_token');
        when(
          () => tokenProvider.getValidToken(forceRefresh: true),
        ).thenAnswer((_) async => 'refreshed_token');

        final response = Response<dynamic>(
          requestOptions: options,
          statusCode: 200,
        );
        when(() => dio.fetch<dynamic>(any())).thenAnswer((_) async => response);
        when(() => errorHandler.resolve(any())).thenAnswer((_) {});

        getInterceptor().onError(error, errorHandler);

        await Future<void>.delayed(Duration.zero);
        verify(() => tokenProvider.getValidToken(forceRefresh: true)).called(1);
        verify(() => dio.fetch<dynamic>(any())).called(1);
        verify(() => errorHandler.resolve(response)).called(1);
      },
    );

    test('should forward refresh error when refresh fails', () async {
      final options = RequestOptions(
        path: '/test',
        baseUrl: testBaseUrl,
        headers: {'Authorization': 'Bearer old_token'},
      );
      final error = DioException(
        requestOptions: options,
        response: Response<dynamic>(requestOptions: options, statusCode: 401),
      );

      when(
        () => tokenProvider.getValidToken(),
      ).thenAnswer((_) async => 'old_token');
      when(
        () => tokenProvider.getValidToken(forceRefresh: true),
      ).thenThrow(Exception('Refresh failed'));
      when(() => errorHandler.next(any())).thenAnswer((_) {});

      getInterceptor().onError(error, errorHandler);

      await Future<void>.delayed(Duration.zero);

      final captured =
          verify(() => errorHandler.next(captureAny())).captured.first
              as DioException;
      expect(captured.message, contains('Token refresh failed'));
    });
  });
}
