import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/app_lock/data/data_sources/app_lock_local_data_source.dart';
import 'package:gatuno/features/app_lock/domain/value_objects/app_lock_grace.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppLockStorage storage;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    storage = AppLockStorage();
  });

  group('AppLockStorage', () {
    test('lock is off by default', () async {
      expect(await storage.isEnabled(), isFalse);
    });

    test('setEnabled round-trips', () async {
      await storage.setEnabled(true);
      expect(await storage.isEnabled(), isTrue);
      await storage.setEnabled(false);
      expect(await storage.isEnabled(), isFalse);
    });

    test('grace defaults to one minute', () async {
      expect(await storage.getGrace(), AppLockGrace.oneMinute);
    });

    test('setGrace round-trips every option', () async {
      for (final grace in AppLockGrace.values) {
        await storage.setGrace(grace);
        expect(await storage.getGrace(), grace);
      }
    });

    test('grace falls back to the default on a corrupt value', () async {
      FlutterSecureStorage.setMockInitialValues({
        'app_lock_grace_seconds': 'not-a-number',
      });
      expect(await AppLockStorage().getGrace(), AppLockGrace.defaultValue);
    });

    test('device credential fallback is allowed by default', () async {
      expect(await storage.isDeviceCredentialAllowed(), isTrue);
    });

    test('setDeviceCredentialAllowed round-trips', () async {
      await storage.setDeviceCredentialAllowed(false);
      expect(await storage.isDeviceCredentialAllowed(), isFalse);
      await storage.setDeviceCredentialAllowed(true);
      expect(await storage.isDeviceCredentialAllowed(), isTrue);
    });
  });
}
