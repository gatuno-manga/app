import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/connectivity/dio_server_probe.dart';
import 'package:gatuno/core/network/api_constants.dart';
import 'package:gatuno/core/network/dio_client.dart';
import 'package:mocktail/mocktail.dart';

class MockDioClient extends Mock implements DioClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late MockDioClient client;
  late MockDio dio;
  late BaseOptions options;

  setUpAll(() => registerFallbackValue(Options()));

  setUp(() {
    client = MockDioClient();
    dio = MockDio();
    options = BaseOptions(baseUrl: 'https://server.example');
    when(() => client.dio).thenReturn(dio);
    when(() => dio.options).thenReturn(options);
  });

  void answer(int status) {
    when(
      () => dio.get<dynamic>(
        ApiConstants.healthLiveness,
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(),
        statusCode: status,
      ),
    );
  }

  test('nothing to probe without a server', () async {
    options.baseUrl = '';
    expect(await dioServerProbe(client)(), isNull);
  });

  test('a 2xx from liveness is online', () async {
    answer(200);
    expect(await dioServerProbe(client)(), isTrue);
  });

  test('an error status, such as a proxy 503, is offline', () async {
    when(
      () => dio.get<dynamic>(
        ApiConstants.healthLiveness,
        options: any(named: 'options'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: RequestOptions(),
          statusCode: 503,
        ),
      ),
    );
    expect(await dioServerProbe(client)(), isFalse);
  });

  test('no answer is offline', () async {
    when(
      () => dio.get<dynamic>(
        ApiConstants.healthLiveness,
        options: any(named: 'options'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.connectionError,
      ),
    );
    expect(await dioServerProbe(client)(), isFalse);
  });
}
