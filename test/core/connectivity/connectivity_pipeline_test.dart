import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/connectivity/connectivity_service.dart';
import 'package:gatuno/core/connectivity/dio_server_probe.dart';
import 'package:gatuno/core/connectivity/server_connectivity_service.dart';
import 'package:gatuno/core/network/api_constants.dart';
import 'package:gatuno/core/network/dio_client.dart';
import 'package:gatuno/core/network/interceptors/connectivity_interceptor.dart';
import 'package:mocktail/mocktail.dart';

class MockDioClient extends Mock implements DioClient {}

/// Times out on every path except the liveness endpoint, whose answer is
/// [healthy], or [healthStatus] when set.
class _ServerAdapter implements HttpClientAdapter {
  bool healthy = true;
  int? healthStatus;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.endsWith(ApiConstants.healthLiveness)) {
      if (!healthy) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      }
      return ResponseBody.fromString(
        jsonEncode({'status': 'ok'}),
        healthStatus ?? 200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.receiveTimeout,
    );
  }

  @override
  void close({bool force = false}) {}
}

/// The probe and the requests share one Dio, as in the app: the probe's own
/// response passes through the connectivity interceptor.
void main() {
  late _ServerAdapter adapter;
  late Dio dio;
  late ServerConnectivityService service;
  var reconnects = 0;

  setUp(() {
    adapter = _ServerAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://server.example'))
      ..httpClientAdapter = adapter;
    final client = MockDioClient();
    when(() => client.dio).thenReturn(dio);
    service = ServerConnectivityService(
      probe: dioServerProbe(client),
      reconnectDebounce: const Duration(milliseconds: 20),
    );
    setupConnectivityInterceptor(client, service);
    reconnects = 0;
    service.onReconnected.listen((_) => reconnects++);
  });

  tearDown(() => service.dispose());

  /// A request that times out, then the confirming probe it started:
  /// checkNow() joins the probe already in flight instead of starting one.
  Future<void> slowRequestConfirmed() async {
    await expectLater(dio.get<dynamic>('/books'), throwsA(isA<DioException>()));
    await service.checkNow();
  }

  /// Longer than the reconnect debounce, so a pending announcement fires.
  Future<void> pastDebounce() =>
      Future<void>.delayed(const Duration(milliseconds: 200));

  test('a slow request on a healthy server is a silent false alarm', () async {
    await slowRequestConfirmed();
    expect(service.status, ConnectivityStatus.online);

    await pastDebounce();
    expect(reconnects, 0);
  });

  test('a real outage that ends announces one reconnect', () async {
    adapter.healthy = false;
    await slowRequestConfirmed();
    expect(service.status, ConnectivityStatus.offline);

    adapter.healthy = true;
    final reconnected = service.onReconnected.first;
    await service.checkNow();
    expect(service.status, ConnectivityStatus.online);

    await reconnected.timeout(const Duration(seconds: 5));
    await pastDebounce();
    expect(reconnects, 1);
  });

  test('an unhealthy liveness answer does not flap the status', () async {
    adapter.healthStatus = 500;
    final statuses = <ConnectivityStatus>[];
    service.statusStream.listen(statuses.add);

    await slowRequestConfirmed();
    await service.checkNow();
    await pastDebounce();

    expect(statuses, [ConnectivityStatus.online, ConnectivityStatus.offline]);
    expect(reconnects, 0);
  });
}
