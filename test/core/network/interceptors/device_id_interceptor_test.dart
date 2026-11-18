import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/device/device_id_service.dart';
import 'package:gatuno/core/network/api_constants.dart';
import 'package:gatuno/core/network/dio_client.dart';
import 'package:gatuno/core/network/interceptors/device_id_interceptor.dart';
import 'package:mocktail/mocktail.dart';

class MockDeviceIdService extends Mock implements DeviceIdService {}

class MockDioClient extends Mock implements DioClient {}

class MockDio extends Mock implements Dio {}

class MockInterceptors extends Mock implements Interceptors {}

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class FakeRequestOptions extends Fake implements RequestOptions {}

class FakeInterceptor extends Fake implements Interceptor {}

void main() {
  const testBaseUrl = 'https://api.gatuno.com/api';
  const testDeviceId = '11111111-2222-4333-8444-555555555555';

  late MockDeviceIdService deviceIdService;
  late MockRequestInterceptorHandler handler;

  setUpAll(() {
    registerFallbackValue(FakeRequestOptions());
    registerFallbackValue(FakeInterceptor());
  });

  setUp(() {
    deviceIdService = MockDeviceIdService();
    handler = MockRequestInterceptorHandler();
    when(
      () => deviceIdService.getDeviceId(),
    ).thenAnswer((_) async => testDeviceId);
    when(() => handler.next(any())).thenAnswer((_) {});
  });

  DeviceIdInterceptor createInterceptor() =>
      DeviceIdInterceptor(deviceIdService: deviceIdService);

  group('DeviceIdInterceptor', () {
    test(
      'attaches x-device-id to API-origin requests including auth',
      () async {
        final paths = [
          '/books',
          ApiConstants.signIn,
          ApiConstants.signUp,
          ApiConstants.authRefresh,
          ApiConstants.mfaVerifyLogin,
        ];

        for (final path in paths) {
          final options = RequestOptions(path: path, baseUrl: testBaseUrl);
          createInterceptor().onRequest(options, handler);
          await Future<void>.delayed(Duration.zero);

          expect(
            options.headers[DeviceIdInterceptor.headerName],
            testDeviceId,
            reason: 'Expected x-device-id on $path',
          );
        }
      },
    );

    test('omits x-device-id when baseUrl is empty', () async {
      final options = RequestOptions(path: '/books', baseUrl: '');

      createInterceptor().onRequest(options, handler);
      await Future<void>.delayed(Duration.zero);

      expect(options.headers[DeviceIdInterceptor.headerName], isNull);
      verifyNever(() => deviceIdService.getDeviceId());
      verify(() => handler.next(options)).called(1);
    });

    test('omits x-device-id for non-API / third-party URLs', () async {
      final externalUrls = [
        'https://s3.amazonaws.com/bucket/cover.jpg',
        'http://api.gatuno.com/api/books',
        'https://api.gatuno.com:8443/api/books',
      ];

      for (final url in externalUrls) {
        final options = RequestOptions(path: url, baseUrl: testBaseUrl);
        createInterceptor().onRequest(options, handler);
        await Future<void>.delayed(Duration.zero);

        expect(
          options.headers[DeviceIdInterceptor.headerName],
          isNull,
          reason: 'Expected x-device-id to be omitted for $url',
        );
      }
      verifyNever(() => deviceIdService.getDeviceId());
    });

    test('setupDeviceIdInterceptor registers DeviceIdInterceptor', () {
      final dioClient = MockDioClient();
      final dio = MockDio();
      final interceptors = MockInterceptors();
      when(() => dioClient.dio).thenReturn(dio);
      when(() => dio.interceptors).thenReturn(interceptors);

      setupDeviceIdInterceptor(dioClient, deviceIdService);

      verify(
        () => interceptors.add(any(that: isA<DeviceIdInterceptor>())),
      ).called(1);
    });
  });
}
