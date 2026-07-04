import 'package:flutter_test/flutter_test.dart';


import 'package:gatuno/core/di/injection.dart';
import 'package:gatuno/features/reading/domain/repositories/reading_repository.dart';
import 'package:gatuno/features/reading/presentation/view_models/reading_view_model.dart';
import 'package:gatuno/features/reading/reading_injection.dart';
import 'package:mocktail/mocktail.dart';


import 'package:gatuno/core/network/dio_client.dart';
import 'package:gatuno/core/network/app_mqtt_service.dart';
import 'package:gatuno/features/authentication/domain/use_cases/auth_service.dart';

class MockDioClient extends Mock implements DioClient {}
class MockAppMqttService extends Mock implements AppMqttService {}
class MockAuthService extends Mock implements AuthService {}

void main() {
  setUp(() {
    sl.reset();
  });

  test('initReadingDI registers expected types', () {
    final mockMqtt = MockAppMqttService();
    when(() => mockMqtt.progressSyncedStream).thenAnswer((_) => const Stream.empty());

    sl.registerSingleton<DioClient>(MockDioClient());
    sl.registerSingleton<AppMqttService>(mockMqtt);
    sl.registerSingleton<AuthService>(MockAuthService());

    initReadingDI(sl);

    expect(sl.isRegistered<ReadingRepository>(), isTrue);
    expect(sl.isRegistered<ReadingViewModel>(), isTrue);
  });
}
