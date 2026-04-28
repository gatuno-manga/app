import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gatuno/features/certificates/presentation/view_models/certificates_view_model.dart';
import 'package:gatuno/features/certificates/domain/use_cases/certificates_service.dart';
import 'package:gatuno/features/certificates/domain/entities/certificate_item.dart';

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

    test('addManualCertificate calls service', () async {
      when(
        () => mockService.addManualCertificate(any(), any()),
      ).thenAnswer((_) async {});

      await viewModel.addManualCertificate('name', 'pem');

      verify(() => mockService.addManualCertificate('name', 'pem')).called(1);
    });

    test('deleteCertificate calls service', () async {
      when(() => mockService.deleteCertificate(any())).thenAnswer((_) async {});

      await viewModel.deleteCertificate('fingerprint');

      verify(() => mockService.deleteCertificate('fingerprint')).called(1);
    });
  });
}
