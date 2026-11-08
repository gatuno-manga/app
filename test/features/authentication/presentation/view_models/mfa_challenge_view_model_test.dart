import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/network/exceptions.dart';
import 'package:gatuno/features/authentication/domain/use_cases/auth_service.dart';
import 'package:gatuno/features/authentication/presentation/view_models/mfa_challenge_view_model.dart';
import 'package:gatuno/features/authentication/presentation/view_models/mfa_error.dart';
import 'package:gatuno/features/authentication/presentation/view_models/signin_view_model.dart';
import 'package:gatuno/features/authentication/domain/value_objects/email_address.dart';
import 'package:gatuno/features/authentication/domain/value_objects/password.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockAuthService auth;
  setUp(() => auth = MockAuthService());

  group('MfaChallengeViewModel', () {
    test('success returns true and trims code', () async {
      when(
        () => auth.verifyMfaLogin('chal', '123456'),
      ).thenAnswer((_) async => true);
      final vm = MfaChallengeViewModel(auth, 'chal');
      expect(await vm.verify(' 123456 '), true);
      expect(vm.state.isLoading, false);
      vm.dispose();
    });

    test('invalid code sets invalidCode', () async {
      when(
        () => auth.verifyMfaLogin(any(), any()),
      ).thenThrow(UnauthorizedException());
      final vm = MfaChallengeViewModel(auth, 'chal');
      expect(await vm.verify('000000'), false);
      expect(vm.state.error, MfaError.invalidCode);
      vm.clearError();
      expect(vm.state.error, isNull);
      vm.dispose();
    });

    test('expired challenge sets challengeExpired', () async {
      when(
        () => auth.verifyMfaLogin(any(), any()),
      ).thenThrow(MfaChallengeExpiredException());
      final vm = MfaChallengeViewModel(auth, 'chal');
      await vm.verify('000000');
      expect(vm.state.error, MfaError.challengeExpired);
      vm.dispose();
    });
  });

  test(
    'SignInViewModel exposes the MFA challenge instead of an error',
    () async {
      registerFallbackValue(EmailAddress('a@b.com'));
      registerFallbackValue(Password('Passw0rd!'));
      when(
        () => auth.signIn(any(), any()),
      ).thenThrow(MfaRequiredException('chal'));
      final vm = SignInViewModel(auth);
      expect(await vm.signIn('a@b.com', 'Passw0rd!'), false);
      expect(vm.state.mfaToken, 'chal');
      expect(vm.state.errorMessage, isNull);
      vm.clearMfaChallenge();
      expect(vm.state.mfaToken, isNull);
      vm.dispose();
    },
  );
}
