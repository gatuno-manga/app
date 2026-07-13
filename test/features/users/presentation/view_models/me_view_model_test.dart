import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gatuno/features/users/presentation/view_models/me_view_model.dart';
import 'package:gatuno/features/users/domain/use_cases/user_service.dart';
import 'package:gatuno/features/users/data/models/user_model.dart';
import 'package:gatuno/features/users/domain/value_objects/user_id.dart';
import 'package:gatuno/features/users/domain/value_objects/user_email.dart';
import 'package:gatuno/features/users/domain/value_objects/user_roles.dart';
import 'package:gatuno/features/users/domain/value_objects/sensitive_content_weight.dart';

class MockUserService extends Mock implements UserService {}

void main() {
  late MeViewModel viewModel;
  late MockUserService mockUserService;

  setUp(() {
    mockUserService = MockUserService();
    viewModel = MeViewModel(mockUserService);
  });

  group('MeViewModel', () {
    test('initial state should be loading and guest', () {
      expect(viewModel.state.isLoading, isTrue);
      expect(viewModel.state.user, equals(UserModel.guest));
    });

    test('init should load user', () async {
      final user = UserModel(
        id: const UserId('1'),
        email: const UserEmail('test@example.com'),
        roles: const UserRoles(['user']),
        maxWeightSensitiveContent: const SensitiveContentWeight(5),
      );

      when(
        () => mockUserService.getCurrentUser(),
      ).thenAnswer((_) async => user);

      await viewModel.init();

      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.user, equals(user));
    });

    test('logout should call service', () async {
      when(() => mockUserService.logout()).thenAnswer((_) async {});

      await viewModel.logout();

      verify(() => mockUserService.logout()).called(1);
    });
  });
}
