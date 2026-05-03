import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/shared/presentation/view_models/navigation_view_model.dart';
import 'package:gatuno/features/users/domain/use_cases/user_service.dart';
import 'package:gatuno/features/authentication/domain/use_cases/auth_service.dart';
import 'package:gatuno/features/users/data/models/user_model.dart';
import 'package:gatuno/features/users/domain/value_objects/user_id.dart';
import 'package:gatuno/features/users/domain/value_objects/user_email.dart';
import 'package:gatuno/features/users/domain/value_objects/user_roles.dart';
import 'package:gatuno/features/users/domain/value_objects/sensitive_content_weight.dart';
import 'package:gatuno/features/users/domain/value_objects/user_display_name.dart';
import 'package:mocktail/mocktail.dart';

class MockUserService extends Mock implements UserService {}

class MockAuthService extends Mock implements AuthService {}

void main() {
  late NavigationViewModel viewModel;
  late MockUserService mockUserService;
  late MockAuthService mockAuthService;

  setUp(() {
    mockUserService = MockUserService();
    mockAuthService = MockAuthService();

    // Default behaviors
    when(() => mockAuthService.authenticated).thenReturn(false);
    when(() => mockAuthService.addListener(any())).thenReturn(null);
    when(() => mockAuthService.removeListener(any())).thenReturn(null);
    when(
      () => mockUserService.getCurrentUser(),
    ).thenAnswer((_) async => UserModel.guest);

    viewModel = NavigationViewModel(mockUserService, mockAuthService);
  });

  group('NavigationViewModel', () {
    test('initial state when not authenticated', () {
      expect(viewModel.isAuthenticated, isFalse);
      expect(viewModel.user, equals(UserModel.guest));
    });

    test('re-loads user when auth state changes', () async {
      final user = UserModel(
        id: const UserId('1'),
        email: const UserEmail('test@example.com'),
        name: const UserDisplayName('Alice'),
        roles: const UserRoles(['user']),
        maxWeightSensitiveContent: const SensitiveContentWeight(0),
      );

      // 1. Initial state: not authenticated
      when(() => mockAuthService.authenticated).thenReturn(false);
      viewModel = NavigationViewModel(mockUserService, mockAuthService);
      expect(viewModel.user, equals(UserModel.guest));

      // 2. Change to authenticated
      when(() => mockAuthService.authenticated).thenReturn(true);
      when(
        () => mockUserService.getCurrentUser(),
      ).thenAnswer((_) async => user);

      // Trigger load manually since we are testing the state transition
      await viewModel.loadUser();

      expect(viewModel.user.isGuest, isFalse);
      expect(viewModel.user.name?.value, equals('Alice'));
      expect(viewModel.isAuthenticated, isTrue);
    });
  });
}
