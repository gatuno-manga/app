import 'package:gatuno/features/authentication/domain/value_objects/email_address.dart';
import 'package:gatuno/features/authentication/domain/value_objects/password.dart';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/authentication/domain/use_cases/auth_service.dart';
import 'package:gatuno/features/authentication/domain/use_cases/token_manager.dart';
import 'package:gatuno/features/authentication/domain/repositories/auth_repository.dart';
import 'package:gatuno/features/authentication/domain/value_objects/auth_token.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockTokenManager extends Mock implements TokenManager {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AuthService authService;
  late MockAuthRepository mockAuthRepository;
  late MockTokenManager mockTokenManager;

  setUpAll(() {
    registerFallbackValue(EmailAddress('test@example.com'));
    registerFallbackValue(Password('password'));
    registerFallbackValue(AuthToken('token'));
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockTokenManager = MockTokenManager();

    // Default mock behavior for constructor's _initAuth
    when(() => mockTokenManager.initialize()).thenAnswer((_) async {});
    when(() => mockTokenManager.currentToken).thenReturn(null);

    authService = AuthService(mockAuthRepository, mockTokenManager);
  });

  final tToken = AuthToken('access');

  group('AuthService', () {
    test(
      'signIn calls repository, saves token and notifies listeners',
      () async {
        var notificationCount = 0;
        authService.authStateStream.listen((_) => notificationCount++);

        when(
          () => mockAuthRepository.signIn(any(), any()),
        ).thenAnswer((_) async => tToken);
        when(
          () => mockTokenManager.saveToken(any()),
        ).thenAnswer((_) async => {});

        final result = await authService.signIn(EmailAddress('test@example.com'), Password('password'));

        expect(result, true);
        expect(authService.authenticated, true);
        expect(notificationCount, greaterThan(0));
        verify(
          () => mockAuthRepository.signIn(EmailAddress('test@example.com'), Password('password')),
        ).called(1);
        verify(() => mockTokenManager.saveToken(tToken)).called(1);
      },
    );

    test(
      'logout calls repository, clears tokens and notifies listeners',
      () async {
        var notificationCount = 0;
        authService.authStateStream.listen((_) => notificationCount++);

        when(() => mockAuthRepository.logout()).thenAnswer((_) async => {});
        when(() => mockTokenManager.clearToken()).thenAnswer((_) async => {});

        await authService.logout();

        expect(authService.authenticated, false);
        expect(notificationCount, greaterThan(0));
        verify(() => mockAuthRepository.logout()).called(1);
        verify(() => mockTokenManager.clearToken()).called(1);
      },
    );

    test(
      'isAuthenticated returns true when token exists and is not expired',
      () async {
        final exp = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
        final payload = base64Url
            .encode(utf8.encode('{"exp": $exp}'))
            .replaceAll('=', '');
        final token = 'header.$payload.signature';

        when(() => mockTokenManager.getToken()).thenAnswer((_) async => token);
        when(() => mockTokenManager.currentToken).thenReturn(token);

        final result = await authService.isAuthenticated();

        expect(result, true);
        verify(() => mockTokenManager.getToken()).called(1);
      },
    );

    test('performTokenRefresh delegates to TokenManager', () async {
      when(
        () => mockTokenManager.performTokenRefresh(),
      ).thenAnswer((_) async {});

      await authService.performTokenRefresh();

      verify(() => mockTokenManager.performTokenRefresh()).called(1);
    });
  });
}
