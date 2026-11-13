import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gatuno/core/theme/app_theme_choice.dart';
import 'package:gatuno/features/settings/data/data_sources/settings_local_data_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SettingsStorage settingsStorage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    settingsStorage = SettingsStorage();
  });

  group('SettingsStorage', () {
    test('setApiUrl and getApiUrl', () async {
      await settingsStorage.setApiUrl('http://test.com');
      expect(await settingsStorage.getApiUrl(), 'http://test.com');
    });

    test('setSensitiveContentEnabled and isSensitiveContentEnabled', () async {
      await settingsStorage.setSensitiveContentEnabled(true);
      expect(await settingsStorage.isSensitiveContentEnabled(), isTrue);

      await settingsStorage.setSensitiveContentEnabled(false);
      expect(await settingsStorage.isSensitiveContentEnabled(), isFalse);
    });

    test('isSensitiveContentEnabled should return false if not set', () async {
      expect(await settingsStorage.isSensitiveContentEnabled(), isFalse);
    });

    test('theme choice defaults to system', () async {
      expect(await settingsStorage.getThemeChoice(), AppThemeChoice.system);
    });

    test('setThemeChoice and getThemeChoice round-trip every choice', () async {
      for (final choice in AppThemeChoice.values) {
        await settingsStorage.setThemeChoice(choice);
        expect(await settingsStorage.getThemeChoice(), choice);
      }
    });

    test('unknown stored theme falls back to system', () async {
      SharedPreferences.setMockInitialValues({'theme_choice': 'neon'});
      expect(await settingsStorage.getThemeChoice(), AppThemeChoice.system);
    });
  });
}
