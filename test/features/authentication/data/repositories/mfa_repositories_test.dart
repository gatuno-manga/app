import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/network/exceptions.dart';
import 'package:gatuno/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:gatuno/features/authentication/data/repositories/mfa_repository_impl.dart';
import 'package:gatuno/features/authentication/domain/value_objects/email_address.dart';
import 'package:gatuno/features/authentication/domain/value_objects/password.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _ok(
  Map<String, dynamic> data, [
  int code = 200,
]) => Response(
  data: data,
  statusCode: code,
  requestOptions: RequestOptions(path: ''),
);

DioException _err(int code, [String? message]) => DioException(
  requestOptions: RequestOptions(path: ''),
  response: Response(
    statusCode: code,
    data: {'message': message},
    requestOptions: RequestOptions(path: ''),
  ),
);

void main() {
  late MockDio dio;
  setUp(() => dio = MockDio());

  group('AuthRepositoryImpl MFA', () {
    late AuthRepositoryImpl repo;
    setUp(() => repo = AuthRepositoryImpl(dio));

    test(
      'signIn throws MfaRequiredException with the challenge token',
      () async {
        when(
          () => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
        ).thenAnswer(
          (_) async => _ok({
            'mfaRequired': true,
            'mfaType': 'totp',
            'mfaToken': 'chal',
          }, 201),
        );
        await expectLater(
          repo.signIn(EmailAddress('a@b.com'), Password('Passw0rd!')),
          throwsA(
            isA<MfaRequiredException>().having(
              (e) => e.mfaToken,
              'token',
              'chal',
            ),
          ),
        );
      },
    );

    test('signIn with mfaRequired but no token is a ServerException', () async {
      when(
        () => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => _ok({'mfaRequired': true}));
      await expectLater(
        repo.signIn(EmailAddress('a@b.com'), Password('Passw0rd!')),
        throwsA(isA<ServerException>()),
      );
    });

    test('verifyMfaLogin returns the token', () async {
      when(
        () => dio.post<Map<String, dynamic>>(
          '/auth/mfa/verify-login',
          data: {'mfaToken': 'chal', 'code': '123456'},
        ),
      ).thenAnswer((_) async => _ok({'accessToken': 'jwt'}, 201));
      final token = await repo.verifyMfaLogin('chal', '123456');
      expect(token.value, 'jwt');
    });

    test('verifyMfaLogin maps a bad challenge token to expired', () async {
      when(
        () => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
      ).thenThrow(_err(401, 'Invalid MFA challenge token'));
      await expectLater(
        repo.verifyMfaLogin('chal', '123456'),
        throwsA(isA<MfaChallengeExpiredException>()),
      );
    });

    test('verifyMfaLogin keeps a wrong code as Unauthorized', () async {
      when(
        () => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
      ).thenThrow(_err(401, 'Invalid MFA code'));
      await expectLater(
        repo.verifyMfaLogin('chal', '000000'),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('verifyMfaLogin maps 429 to TooManyRequestsException', () async {
      when(
        () => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
      ).thenThrow(_err(429, 'Too Many Requests'));
      await expectLater(
        repo.verifyMfaLogin('chal', '000000'),
        throwsA(isA<TooManyRequestsException>()),
      );
    });
  });

  group('MfaRepositoryImpl', () {
    late MfaRepositoryImpl repo;
    setUp(() => repo = MfaRepositoryImpl(dio));

    test('status parses', () async {
      when(() => dio.get<Map<String, dynamic>>('/auth/mfa/status')).thenAnswer(
        (_) async => _ok({'totpEnabled': true, 'backupCodesRemaining': 7}),
      );
      final s = await repo.status();
      expect(s.totpEnabled, true);
      expect(s.backupCodesRemaining, 7);
    });

    test('setupTotp parses secret and uri', () async {
      when(
        () => dio.post<Map<String, dynamic>>('/auth/mfa/totp/setup'),
      ).thenAnswer(
        (_) async => _ok({'secret': 'ABC', 'otpauthUri': 'otpauth://x'}, 201),
      );
      final s = await repo.setupTotp();
      expect(s.secret, 'ABC');
      expect(s.otpauthUri, 'otpauth://x');
    });

    test('setupTotp with malformed body is a ServerException', () async {
      when(
        () => dio.post<Map<String, dynamic>>('/auth/mfa/totp/setup'),
      ).thenAnswer((_) async => _ok({'secret': 1}));
      await expectLater(repo.setupTotp(), throwsA(isA<ServerException>()));
    });

    test('verifyTotpSetup returns backup codes', () async {
      when(
        () => dio.post<Map<String, dynamic>>(
          '/auth/mfa/totp/verify-setup',
          data: {'code': '123456'},
        ),
      ).thenAnswer(
        (_) async => _ok({
          'enabled': true,
          'backupCodes': ['A-1', 'B-2'],
        }, 201),
      );
      final r = await repo.verifyTotpSetup('123456');
      expect(r.codes, ['A-1', 'B-2']);
      expect(r.toString(), isNot(contains('A-1')));
    });

    test('status with a malformed body is a ServerException', () async {
      when(
        () => dio.get<Map<String, dynamic>>('/auth/mfa/status'),
      ).thenAnswer((_) async => _ok({}));
      await expectLater(repo.status(), throwsA(isA<ServerException>()));
    });

    test('disableTotp sends the code', () async {
      when(
        () => dio.post<Map<String, dynamic>>(
          '/auth/mfa/totp/disable',
          data: {'code': '123456'},
        ),
      ).thenAnswer((_) async => _ok({'enabled': false}, 201));
      await repo.disableTotp('123456');
    });

    test('401 surfaces as UnauthorizedException', () async {
      when(
        () => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
      ).thenThrow(_err(401, 'Invalid MFA verification code'));
      await expectLater(
        repo.verifyTotpSetup('1'),
        throwsA(isA<UnauthorizedException>()),
      );
    });
  });
}
