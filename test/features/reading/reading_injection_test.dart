import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:gatuno/core/di/injection.dart';
import 'package:gatuno/features/reading/data/database/reading_database.dart';
import 'package:gatuno/features/reading/domain/repositories/reading_repository.dart';
import 'package:gatuno/features/reading/domain/use_cases/reader_preferences_service.dart';
import 'package:gatuno/features/reading/presentation/view_models/reading_view_model.dart';
import 'package:gatuno/features/reading/reading_injection.dart';
import 'package:mocktail/mocktail.dart';

import 'package:gatuno/core/network/dio_client.dart';
import 'package:gatuno/core/network/app_mqtt_service.dart';
import 'package:gatuno/features/authentication/domain/use_cases/auth_service.dart';

import '../../helpers/path_provider_mock.dart';

class MockDioClient extends Mock implements DioClient {}

class MockAppMqttService extends Mock implements AppMqttService {}

class MockAuthService extends Mock implements AuthService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    await sl.reset();
    tempDir = Directory.systemTemp.createTempSync('gatuno-reading-di-test');
    mockPathProvider(tempDir);
  });

  tearDown(() async {
    // initReadingDI builds the reading database; close it so it cannot open
    // a file after this test has ended.
    await Future<void>.delayed(Duration.zero);
    if (sl.isRegistered<ReadingDatabase>()) {
      await sl<ReadingDatabase>().close();
    }
    await sl.reset();
    clearPathProviderMock();
    tempDir.deleteSync(recursive: true);
  });

  test('initReadingDI registers expected types', () {
    final mockMqtt = MockAppMqttService();
    when(
      () => mockMqtt.progressSyncedStream,
    ).thenAnswer((_) => const Stream.empty());

    sl.registerSingleton<DioClient>(MockDioClient());
    sl.registerSingleton<AppMqttService>(mockMqtt);
    sl.registerSingleton<AuthService>(MockAuthService());

    initReadingDI(sl);

    expect(sl.isRegistered<ReadingRepository>(), isTrue);
    expect(sl.isRegistered<ReadingViewModel>(), isTrue);
    expect(sl.isRegistered<ReaderPreferencesService>(), isTrue);
  });
}
