import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gatuno/core/network/interceptors/bad_certificate_interceptor.dart';
import 'package:gatuno/features/certificates/domain/use_cases/certificates_service.dart';

class MockCertificatesService extends Mock implements CertificatesService {}

class MockDio extends Mock implements Dio {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

class MockX509Certificate extends Mock implements X509Certificate {}

class FakeDioException extends Fake implements DioException {}

void main() {
  late BadCertificateInterceptor interceptor;
  late MockCertificatesService mockService;
  late MockDio mockDio;
  late MockErrorInterceptorHandler mockHandler;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(FakeDioException());
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockService = MockCertificatesService();
    mockDio = MockDio();
    mockHandler = MockErrorInterceptorHandler();
    interceptor = BadCertificateInterceptor(mockService, mockDio);
  });

  group('BadCertificateInterceptor', () {
    test('passes error to next if not a badCertificate type', () async {
      final err = DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      );

      when(() => mockHandler.next(any())).thenAnswer((_) {});

      await interceptor.onError(err, mockHandler);

      verify(() => mockHandler.next(err)).called(1);
    });

    test('passes error to next if no pending cert found for host', () async {
      final options = RequestOptions(path: 'https://test.com');
      final err = DioException(
        requestOptions: options,
        type: DioExceptionType.badCertificate,
      );

      when(() => mockService.getPending('test.com')).thenReturn(null);
      when(() => mockHandler.next(any())).thenAnswer((_) {});

      await interceptor.onError(err, mockHandler);

      verify(() => mockHandler.next(err)).called(1);
    });

    test(
      'intercepts and handles HandshakeException wrapped in DioExceptionType.unknown',
      () async {
        final options = RequestOptions(path: 'https://test.com');
        final cert = MockX509Certificate();
        final handshakeException = HandshakeException(
          'Handshake error in client (OS Error: CERTIFICATE_VERIFY_FAILED: self signed certificate in certificate chain)',
        );
        final err = DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          error: handshakeException,
        );

        when(() => mockService.getPending('test.com')).thenReturn(cert);
        when(() => mockHandler.next(any())).thenAnswer((_) {});

        // Note: This test will attempt to show a dialog which requires context.
        // In unit tests, rootNavigatorKey.currentContext is null, so it should log and pass to next.
        await interceptor.onError(err, mockHandler);

        verify(() => mockService.getPending('test.com')).called(1);
        verify(() => mockHandler.next(err)).called(1);
      },
    );
  });
}
