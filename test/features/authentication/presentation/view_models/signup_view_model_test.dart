import 'package:gatuno/features/authentication/domain/value_objects/email_address.dart';
import 'package:gatuno/features/authentication/domain/value_objects/password.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/authentication/presentation/view_models/signup_view_model.dart';
import 'package:gatuno/features/authentication/domain/use_cases/auth_service.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late SignUpViewModel viewModel;
  late MockAuthService mockAuthService;

  
  setUpAll(() {
    registerFallbackValue(EmailAddress('test@example.com'));
    registerFallbackValue(Password('password'));
  });

  setUp(() {
    mockAuthService = MockAuthService();
    viewModel = SignUpViewModel(mockAuthService);
  });

  group('SignUpViewModel', () {
    test('initial state is correct', () {
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
    });

    test('signUp success updates state correctly', () async {
      when(
        () => mockAuthService.signUp(EmailAddress('test@example.com'), Password('Password123!')),
      ).thenAnswer((_) async => true);

      final success = await viewModel.signUp(
        'test@example.com',
        'Password123!',
      );

      expect(success, true);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
    });

    test('signUp failure updates state correctly', () async {
      when(
        () => mockAuthService.signUp(any(), any()),
      ).thenThrow(Exception('Signup failed'));

      final success = await viewModel.signUp(
        'test@example.com',
        'Password123!',
      );

      expect(success, false);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, 'Exception: Signup failed');
    });

    test('clearError resets error message', () async {
      when(
        () => mockAuthService.signUp(any(), any()),
      ).thenThrow(Exception('Error'));

      await viewModel.signUp('test@example.com', 'Password123!');
      viewModel.clearError();

      expect(viewModel.errorMessage, null);
    });
  });
}
