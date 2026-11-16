import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/di/background_injection.dart';
import 'package:gatuno/core/di/injection.dart';
import 'package:gatuno/core/network/app_mqtt_service.dart';
import 'package:gatuno/features/downloads/data/data_sources/workmanager_check_scheduler.dart';
import 'package:gatuno/features/downloads/domain/use_cases/checking_auto_download_preferences.dart';
import 'package:gatuno/features/downloads/domain/repositories/auto_download_preferences.dart';
import 'package:gatuno/features/downloads/domain/repositories/download_service.dart';
import 'package:gatuno/features/downloads/domain/repositories/new_chapter_check_scheduler.dart';
import 'package:gatuno/features/downloads/domain/use_cases/new_chapter_check.dart';
import 'package:gatuno/features/authentication/domain/use_cases/auth_service.dart';
import 'package:gatuno/features/users/domain/use_cases/user_service.dart';
import 'package:gatuno/features/home/presentation/view_models/home_view_model.dart';
import 'package:gatuno/core/network/dio_client.dart';
import 'package:gatuno/features/downloads/domain/repositories/download_network_policy.dart';
import 'package:gatuno/features/downloads/domain/repositories/download_network_rules.dart';
import 'package:gatuno/features/settings/presentation/view_models/download_settings_view_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/di_teardown.dart';
import '../../helpers/path_provider_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Injection', () {
    late Directory tempDir;

    setUp(() async {
      await sl.reset();
      tempDir = Directory.systemTemp.createTempSync('gatuno-di-test');
      SharedPreferences.setMockInitialValues({});
      // initDI yields to the event loop while it awaits, so the eagerly
      // opened reading database (MQTT handler) and the HTTP cache store run
      // inside the test and need a real directory, not the working one.
      mockPathProvider(tempDir);
    });

    tearDown(() async {
      await tearDownInjectionTest();
      clearPathProviderMock();
      tempDir.deleteSync(recursive: true);
    });

    test('initDI registers all dependencies', () async {
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({});

      await initDI();

      expect(sl.isRegistered<DioClient>(), true);
      expect(sl.isRegistered<AuthService>(), true);
      expect(sl.isRegistered<UserService>(), true);
      expect(sl.isRegistered<HomeViewModel>(), true);
      // The engine obeys the rules the settings screen edits.
      expect(sl<DownloadNetworkPolicy>(), same(sl<DownloadNetworkRules>()));
      expect(sl.isRegistered<DownloadSettingsViewModel>(), true);
      // Automatic download: the setting checks and schedules, through the
      // workmanager adapter.
      expect(
        sl<AutoDownloadPreferences>(),
        isA<CheckingAutoDownloadPreferences>(),
      );
      expect(sl<NewChapterCheckScheduler>(), isA<WorkmanagerCheckScheduler>());
      expect(sl.isRegistered<NewChapterCheck>(), true);
    });

    test('initBackgroundDI registers only what the check needs', () async {
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({});

      await initBackgroundDI();

      expect(sl<NewChapterCheck>(), isNotNull);
      expect(sl.isRegistered<DownloadService>(), true);
      expect(sl.isRegistered<AuthService>(), true);
      expect(sl.isRegistered<AppMqttService>(), false);
      expect(sl.isRegistered<UserService>(), false);
    });
  });
}
