import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gatuno/features/users/presentation/views/me_screen.dart';
import 'package:gatuno/features/users/presentation/view_models/me_view_model.dart';
import 'package:gatuno/features/users/domain/use_cases/user_service.dart';
import 'package:gatuno/features/users/data/models/user_model.dart';
import 'package:gatuno/features/users/domain/value_objects/user_id.dart';
import 'package:gatuno/features/users/domain/value_objects/user_email.dart';
import 'package:gatuno/features/users/domain/value_objects/user_roles.dart';
import 'package:gatuno/features/users/domain/value_objects/sensitive_content_weight.dart';
import 'package:gatuno/features/users/domain/value_objects/user_display_name.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/test_injection.dart';

class MockUserService extends Mock implements UserService {}

void main() {
  late MockUserService mockUserService;
  late MockAuthService mockAuthService;
  late MeViewModel meViewModel;

  setUp(() async {
    mockUserService = MockUserService();
    mockAuthService = MockAuthService();
    meViewModel = MeViewModel(mockUserService);

    await initTestDI(authService: mockAuthService, meViewModel: meViewModel);

    when(() => mockUserService.getCurrentUser()).thenAnswer(
      (_) async => UserModel(
        id: const UserId('1'),
        email: const UserEmail('test@example.com'),
        roles: const UserRoles(['user']),
        maxWeightSensitiveContent: const SensitiveContentWeight(5),
        name: const UserDisplayName('Test User'),
      ),
    );
  });

  testWidgets('MePage renders correctly and handles logout', (tester) async {
    await tester.pumpApp(const MePage());
    await tester.pumpAndSettle();

    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);

    // Test logout
    when(() => mockUserService.logout()).thenAnswer((_) async {});

    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();

    verify(() => mockUserService.logout()).called(1);
    expect(find.text('Settings Page'), findsOneWidget);
  });
}
