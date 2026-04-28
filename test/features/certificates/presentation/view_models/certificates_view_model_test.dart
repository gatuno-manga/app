import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gatuno/features/certificates/presentation/view_models/certificates_view_model.dart';
import 'package:gatuno/features/certificates/domain/use_cases/certificates_service.dart';
import 'package:gatuno/features/certificates/domain/entities/certificate_item.dart';
import 'package:gatuno/features/certificates/exceptions/certificates_exceptions.dart';

class MockCertificatesService extends Mock implements CertificatesService {}

void main() {
  late CertificatesViewModel viewModel;
  late MockCertificatesService mockService;

  setUp(() {
    mockService = MockCertificatesService();
    // Stub the listeners
    when(() => mockService.addListener(any())).thenAnswer((_) {});
    when(() => mockService.removeListener(any())).thenAnswer((_) {});

    viewModel = CertificatesViewModel(mockService);
  });

  group('CertificatesViewModel', () {
    final certItem = CertificateItem(
      name: 'test.com',
      fingerprint: 'abc',
      pem: 'pem',
      subject: 'sub',
      issuer: 'iss',
      isIgnored: false,
      addedAt: DateTime.now(),
    );

    test('exposes trusted and ignored certificates from service', () {
      when(() => mockService.trustedCertificates).thenReturn([certItem]);
      when(() => mockService.ignoredCertificates).thenReturn([]);

      expect(viewModel.trustedCertificates.length, 1);
      expect(viewModel.trustedCertificates.first.name, 'test.com');
      expect(viewModel.ignoredCertificates, isEmpty);
    });

    test('addManualCertificate returns true on success', () async {
      when(
        () => mockService.addManualCertificate(any(), any()),
      ).thenAnswer((_) async {});

      final result = await viewModel.addManualCertificate('name', 'pem');

      expect(result, isTrue);
      expect(viewModel.error, isNull);
      verify(() => mockService.addManualCertificate('name', 'pem')).called(1);
    });

    test(
      'addManualCertificate returns false and sets error on CertificateException',
      () async {
        when(
          () => mockService.addManualCertificate(any(), any()),
        ).thenThrow(CertificateEmptyFingerprintException());

        final result = await viewModel.addManualCertificate('name', 'pem');

        expect(result, isFalse);
        expect(viewModel.error, isA<CertificateEmptyFingerprintException>());
        verify(() => mockService.addManualCertificate('name', 'pem')).called(1);
      },
    );

    test(
      'addManualCertificate returns false and sets DecodingException on unknown error',
      () async {
        when(
          () => mockService.addManualCertificate(any(), any()),
        ).thenThrow(Exception('unknown'));

        final result = await viewModel.addManualCertificate('name', 'pem');

        expect(result, isFalse);
        expect(viewModel.error, isA<CertificateDecodingException>());
      },
    );

    test('clearError resets error state', () {
      // Manual trigger to set error (if possible, or just set it via a failed call)
      when(
        () => mockService.addManualCertificate(any(), any()),
      ).thenThrow(CertificateDecodingException());

      viewModel.addManualCertificate('n', 'p');
      expect(viewModel.error, isNotNull);

      viewModel.clearError();
      expect(viewModel.error, isNull);
    });

    test('deleteCertificate calls service', () async {
      when(() => mockService.deleteCertificate(any())).thenAnswer((_) async {});

      await viewModel.deleteCertificate('fingerprint');

      verify(() => mockService.deleteCertificate('fingerprint')).called(1);
    });
  });
}
