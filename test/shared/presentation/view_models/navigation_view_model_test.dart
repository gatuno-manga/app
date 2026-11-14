import 'dart:async';
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
import 'package:gatuno/core/connectivity/connectivity_service.dart';

class MockUserService extends Mock implements UserService {}

class MockAuthService extends Mock implements AuthService {}

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late NavigationViewModel viewModel;
  late MockUserService mockUserService;
  late MockAuthService mockAuthService;
  late MockConnectivityService connectivity;
  late StreamController<ConnectivityStatus> statuses;

  setUp(() {
    connectivity = MockConnectivityService();
    statuses = StreamController<ConnectivityStatus>.broadcast();
    when(() => connectivity.statusStream).thenAnswer((_) => statuses.stream);

    mockUserService = MockUserService();
    mockAuthService = MockAuthService();

    // Default behaviors
    when(() => mockAuthService.authenticated).thenReturn(false);
    when(
      () => mockAuthService.authStateStream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockUserService.getCurrentUser(),
    ).thenAnswer((_) async => UserModel.guest);

    viewModel = NavigationViewModel(
      mockUserService,
      mockAuthService,
      connectivity,
    );
  });

  tearDown(() => statuses.close());

  group('NavigationViewModel', () {
    test('mirrors the connectivity status as isOffline', () async {
      expect(viewModel.state.isOffline, isFalse);

      statuses.add(ConnectivityStatus.offline);
      await Future<void>.delayed(Duration.zero);
      expect(viewModel.state.isOffline, isTrue);

      statuses.add(ConnectivityStatus.online);
      await Future<void>.delayed(Duration.zero);
      expect(viewModel.state.isOffline, isFalse);
    });

    test('stops listening to connectivity on dispose', () async {
      viewModel.dispose();
      expect(statuses.hasListener, isFalse);
    });

    test('initial state when not authenticated', () {
      expect(viewModel.state.isAuthenticated, isFalse);
      expect(viewModel.state.user, equals(UserModel.guest));
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
      viewModel = NavigationViewModel(
        mockUserService,
        mockAuthService,
        connectivity,
      );
      expect(viewModel.state.user, equals(UserModel.guest));

      // 2. Change to authenticated
      when(() => mockAuthService.authenticated).thenReturn(true);
      when(
        () => mockUserService.getCurrentUser(),
      ).thenAnswer((_) async => user);

      // Simulate stream event to trigger onAuthStateChanged
      final controller = StreamController<AuthState>();
      when(
        () => mockAuthService.authStateStream,
      ).thenAnswer((_) => controller.stream);
      // We must re-init the viewmodel for it to pick up the new stream mock
      viewModel = NavigationViewModel(
        mockUserService,
        mockAuthService,
        connectivity,
      );

      controller.add(AuthState.authenticated);

      // Wait for stream and futures
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.user.isGuest, isFalse);
      expect(viewModel.state.user.name?.value, equals('Alice'));
      expect(viewModel.state.isAuthenticated, isTrue);

      await controller.close();
    });
  });
}
