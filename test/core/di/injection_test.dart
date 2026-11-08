import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/di/injection.dart';
import 'package:gatuno/features/authentication/domain/use_cases/auth_service.dart';
import 'package:gatuno/features/users/domain/use_cases/user_service.dart';
import 'package:gatuno/features/home/presentation/view_models/home_view_model.dart';
import 'package:gatuno/core/network/dio_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Injection', () {
    const MethodChannel channel = MethodChannel(
      'plugins.flutter.io/path_provider',
    );

    late Directory tempDir;

    setUp(() async {
      await sl.reset();
      tempDir = Directory.systemTemp.createTempSync('gatuno-di-test');
      SharedPreferences.setMockInitialValues({});
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'getApplicationCacheDirectory') {
              return '.';
            }
            // initDI awaits ReaderPreferencesService.init(), which yields to
            // the event loop, so the eagerly opened reading database (MQTT
            // handler) now runs inside the test and needs a temp directory.
            if (methodCall.method == 'getTemporaryDirectory') {
              return tempDir.path;
            }
            return null;
          });
    });

    tearDown(() async {
      await sl.reset();
      tempDir.deleteSync(recursive: true);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('initDI registers all dependencies', () async {
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({});

      await initDI();

      expect(sl.isRegistered<DioClient>(), true);
      expect(sl.isRegistered<AuthService>(), true);
      expect(sl.isRegistered<UserService>(), true);
      expect(sl.isRegistered<HomeViewModel>(), true);
    });
  });
}
