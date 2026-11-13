import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/settings/data/data_sources/settings_migration.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockSecure extends Mock implements FlutterSecureStorage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// A fresh instance per call: it binds to the mock platform at creation.
  FlutterSecureStorage secureWith(Map<String, String> values) {
    FlutterSecureStorage.setMockInitialValues(values);
    return const FlutterSecureStorage();
  }

  Future<SharedPreferences> prefsWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  test('copies values to prefs and removes them from secure storage', () async {
    final secure = secureWith({
      'api_base_url': 'http://a.test',
      'sensitive_content_enabled': 'true',
      'last_sync_at_u1': '2026-01-01T00:00:00.000Z',
      'last_sync_at_u2': '2026-02-01T00:00:00.000Z',
      'access_token': 'secret',
    });
    final prefs = await prefsWith({});

    await SettingsMigration(secure: secure).run();

    expect(prefs.getString('api_base_url'), 'http://a.test');
    expect(prefs.getBool('sensitive_content_enabled'), isTrue);
    expect(prefs.getString('last_sync_at_u1'), '2026-01-01T00:00:00.000Z');
    expect(prefs.getString('last_sync_at_u2'), '2026-02-01T00:00:00.000Z');
    expect(prefs.getBool(SettingsMigration.doneKey), isTrue);
    final left = await secure.readAll();
    expect(left, {'access_token': 'secret'});
  });

  test('prefs wins when both stores hold a value', () async {
    final secure = secureWith({'api_base_url': 'http://old.test'});
    final prefs = await prefsWith({'api_base_url': 'http://new.test'});

    await SettingsMigration(secure: secure).run();

    expect(prefs.getString('api_base_url'), 'http://new.test');
    expect(await secure.read(key: 'api_base_url'), isNull);
  });

  test('stored false stays false', () async {
    final secure = secureWith({'sensitive_content_enabled': 'false'});
    final prefs = await prefsWith({});

    await SettingsMigration(secure: secure).run();

    expect(prefs.getBool('sensitive_content_enabled'), isFalse);
  });

  test('second run is a no-op once done', () async {
    final secure = secureWith({'api_base_url': 'http://a'});
    final prefs = await prefsWith({});
    await SettingsMigration(secure: secure).run();

    await secure.write(key: 'api_base_url', value: 'http://late');
    await SettingsMigration(secure: secure).run();

    expect(prefs.getString('api_base_url'), 'http://a');
    expect(await secure.read(key: 'api_base_url'), 'http://late');
  });

  test('fresh install sets the flag and touches nothing else', () async {
    final secure = secureWith({});
    final prefs = await prefsWith({});

    await SettingsMigration(secure: secure).run();

    expect(prefs.getKeys(), {SettingsMigration.doneKey});
  });

  test(
    'failure leaves the flag unset, keeps the value and does not throw',
    () async {
      final failing = _MockSecure();
      when(
        () => failing.readAll(),
      ).thenAnswer((_) async => {'api_base_url': 'http://a.test'});
      when(
        () => failing.delete(key: any(named: 'key')),
      ).thenThrow(Exception('keystore locked'));
      final prefs = await prefsWith({});

      await SettingsMigration(secure: failing).run();

      expect(prefs.getBool(SettingsMigration.doneKey), isNull);
      expect(prefs.getString('api_base_url'), 'http://a.test');

      // Next launch with a working store finishes the job.
      final secure = secureWith({'api_base_url': 'http://a.test'});
      await SettingsMigration(secure: secure).run();
      expect(prefs.getBool(SettingsMigration.doneKey), isTrue);
      expect(await secure.read(key: 'api_base_url'), isNull);
    },
  );
}
