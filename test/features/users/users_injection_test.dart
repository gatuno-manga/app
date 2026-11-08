import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/di/injection.dart';
import 'package:gatuno/core/network/dio_client.dart';
import 'package:gatuno/features/authentication/domain/use_cases/auth_service.dart';
import 'package:gatuno/features/users/domain/use_cases/user_service.dart';
import 'package:gatuno/features/users/users_injection.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_injection.dart';

void main() {
  late MockAuthService authService;

  setUp(() async {
    await sl.reset();
    authService = MockAuthService();
    when(
      () => authService.authStateStream,
    ).thenAnswer((_) => const Stream.empty());
    sl.registerSingleton<AuthService>(authService);
    sl.registerSingleton<DioClient>(MockDioClient());
  });

  tearDown(() => sl.reset());

  test('UserService starts listening to auth state at registration', () {
    initUsersInjection(sl);

    // Eager creation: the sign-in refresh must run even before any screen
    // resolves the service.
    verify(() => authService.authStateStream).called(1);
    expect(sl.isRegistered<UserService>(), isTrue);
  });
}
