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

  test('registers UserService without touching auth state', () {
    initUsersInjection(sl);

    // Listening starts in initDI (UserService.init) only after the Dio
    // interceptors are installed, so the first /me carries the token.
    verifyNever(() => authService.authStateStream);
    expect(sl.isRegistered<UserService>(), isTrue);
  });

  test('init attaches the auth listener once', () {
    initUsersInjection(sl);

    sl<UserService>().init();

    verify(() => authService.authStateStream).called(1);
  });
}
