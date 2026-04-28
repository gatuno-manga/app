import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/network/dio_client.dart';
import 'package:gatuno/core/network/interceptors/logging_interceptor.dart';
import 'package:gatuno/core/network/interceptors/cache_interceptor.dart';
import 'package:gatuno/features/certificates/domain/use_cases/certificates_service.dart';
import 'package:mocktail/mocktail.dart';

class MockX509Certificate extends Mock implements X509Certificate {}

class MockHttpClient extends Mock implements HttpClient {}

class MockCertificatesService extends Mock implements CertificatesService {}

void main() {
  late MockCertificatesService mockCertificatesService;

  setUp(() {
    mockCertificatesService = MockCertificatesService();
    registerFallbackValue(MockX509Certificate());
  });

  group('DioClient', () {
    test('provides a Dio instance with correct base options', () {
      final client = DioClient(
        certificatesService: mockCertificatesService,
        baseUrl: 'https://api.test.com',
      );
      expect(client.dio, isA<Dio>());
      expect(client.dio.options.baseUrl, 'https://api.test.com');
      expect(client.dio.options.contentType, 'application/json');
    });

    test(
      'configures IOHttpClientAdapter with correct badCertificateCallback',
      () {
        const baseUrl = 'https://api.test.com/api';
        final mockHttpClient = MockHttpClient();

        when(
          () => mockCertificatesService.checkStatus(any(), any()),
        ).thenReturn(CertificateStatus.trusted);

        final client = DioClient(
          certificatesService: mockCertificatesService,
          baseUrl: baseUrl,
          httpClient: mockHttpClient,
        );

        final adapter = client.dio.httpClientAdapter as IOHttpClientAdapter;
        final httpClient = adapter.createHttpClient!();
        expect(httpClient, mockHttpClient);

        final cert = MockX509Certificate();

        final capturedCallback =
            verify(
                  () => mockHttpClient.badCertificateCallback = captureAny(),
                ).captured.single
                as bool Function(X509Certificate, String, int);

        expect(capturedCallback(cert, 'api.test.com', 443), isTrue);
        verify(
          () => mockCertificatesService.checkStatus(cert, 'api.test.com'),
        ).called(1);
      },
    );

    test('setupLoggingInterceptor adds LoggingInterceptor', () {
      final client = DioClient(certificatesService: mockCertificatesService);
      setupLoggingInterceptor(client);

      final loggingInterceptors = client.dio.interceptors
          .whereType<LoggingInterceptor>();
      expect(loggingInterceptors, isNotEmpty);
    });

    test('setupCacheInterceptor adds DioCacheInterceptor', () async {
      final client = DioClient(certificatesService: mockCertificatesService);
      await setupCacheInterceptor(client, store: MemCacheStore());

      final cacheInterceptors = client.dio.interceptors
          .whereType<DioCacheInterceptor>();
      expect(cacheInterceptors, isNotEmpty);
    });
  });
}
