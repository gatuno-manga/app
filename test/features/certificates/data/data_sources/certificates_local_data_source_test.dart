import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gatuno/features/certificates/data/data_sources/certificates_local_data_source.dart';
import 'package:gatuno/features/certificates/domain/entities/certificate_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CertificatesStorage storage;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    storage = CertificatesStorage();
  });

  group('CertificatesStorage', () {
    final certList = [
      CertificateItem(
        host: 'test.com',
        fingerprint: 'abc',
        pem: 'pem_data',
        subject: 'subject',
        issuer: 'issuer',
        isIgnored: false,
        addedAt: DateTime(2023, 1, 1),
      ),
    ];

    test('getCertificates returns empty list initially', () async {
      final certs = await storage.getCertificates();
      expect(certs, isEmpty);
    });

    test('setCertificates and getCertificates', () async {
      await storage.setCertificates(certList);
      final certs = await storage.getCertificates();
      expect(certs.length, 1);
      expect(certs.first.host, 'test.com');
      expect(certs.first.fingerprint, 'abc');
      expect(certs.first.pem, 'pem_data');
      expect(certs.first.isIgnored, isFalse);
      expect(certs.first.addedAt, DateTime(2023, 1, 1));
    });

    test('getCertificates returns empty list on invalid json', () async {
      const secureStorage = FlutterSecureStorage();
      await secureStorage.write(key: 'certificates', value: 'invalid_json');
      
      final certs = await storage.getCertificates();
      expect(certs, isEmpty);
    });
  });
}
