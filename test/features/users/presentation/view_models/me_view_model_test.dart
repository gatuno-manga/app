import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gatuno/features/users/presentation/view_models/me_view_model.dart';
import 'package:gatuno/features/users/domain/use_cases/user_service.dart';
import 'package:gatuno/features/users/data/models/user_model.dart';
import 'package:gatuno/features/users/domain/value_objects/profile_image_failure.dart';
import 'package:gatuno/features/users/domain/value_objects/profile_image_kind.dart';
import 'package:gatuno/features/users/domain/value_objects/user_id.dart';
import 'package:gatuno/features/users/domain/value_objects/user_email.dart';
import 'package:gatuno/features/users/domain/value_objects/user_roles.dart';
import 'package:gatuno/features/users/domain/value_objects/sensitive_content_weight.dart';

class MockUserService extends Mock implements UserService {}

void main() {
  setUpAll(() {
    registerFallbackValue(ProfileImageKind.avatar);
    registerFallbackValue(Uint8List(0));
  });

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
      when(
        () => mockUserService.refreshProfile(),
      ).thenAnswer((_) async => null);

      await viewModel.init();

      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.user, equals(user));
    });

    test('logout should call service', () async {
      when(() => mockUserService.logout()).thenAnswer((_) async {});

      await viewModel.logout();

      verify(() => mockUserService.logout()).called(1);
    });

    test('init shows the cached user then the refreshed one', () async {
      final cached = UserModel(
        id: const UserId('1'),
        email: const UserEmail('a@b.c'),
        roles: const UserRoles(['user']),
        maxWeightSensitiveContent: const SensitiveContentWeight(0),
      );
      final fresh = UserModel(
        id: const UserId('1'),
        email: const UserEmail('a@b.c'),
        roles: const UserRoles(['user']),
        maxWeightSensitiveContent: const SensitiveContentWeight(0),
        profilePictureUrl: 'http://x/a.webp',
      );
      when(
        () => mockUserService.getCurrentUser(),
      ).thenAnswer((_) async => cached);
      when(
        () => mockUserService.refreshProfile(),
      ).thenAnswer((_) async => fresh);

      await viewModel.init();

      expect(viewModel.state.user.profilePictureUrl, 'http://x/a.webp');
    });

    test('init does not refresh for guests', () async {
      when(
        () => mockUserService.getCurrentUser(),
      ).thenAnswer((_) async => UserModel.guest);
      await viewModel.init();
      verifyNever(() => mockUserService.refreshProfile());
    });

    test('uploadImage toggles uploading and updates the user', () async {
      final updated = UserModel(
        id: const UserId('1'),
        email: const UserEmail('a@b.c'),
        roles: const UserRoles(['user']),
        maxWeightSensitiveContent: const SensitiveContentWeight(0),
        profilePictureUrl: 'http://x/new.webp',
      );
      when(
        () => mockUserService.uploadProfileImage(
          kind: ProfileImageKind.avatar,
          fileName: 'a.png',
          bytes: any(named: 'bytes'),
        ),
      ).thenAnswer((_) async => updated);

      final states = <Set<ProfileImageKind>>[];
      final sub = viewModel.stateStream.listen((s) => states.add(s.uploading));
      final failure = await viewModel.uploadImage(
        kind: ProfileImageKind.avatar,
        fileName: 'a.png',
        bytes: Uint8List(1),
      );
      await sub.cancel();

      expect(failure, isNull);
      expect(states.any((s) => s.contains(ProfileImageKind.avatar)), isTrue);
      expect(viewModel.state.uploading, isEmpty);
      expect(viewModel.state.user, updated);
    });

    test('uploadImage returns the failure and keeps the user', () async {
      when(
        () => mockUserService.uploadProfileImage(
          kind: any(named: 'kind'),
          fileName: any(named: 'fileName'),
          bytes: any(named: 'bytes'),
        ),
      ).thenThrow(
        const ProfileImageFailure(
          ProfileImageFailureReason.tooLarge,
          ProfileImageKind.banner,
        ),
      );

      final failure = await viewModel.uploadImage(
        kind: ProfileImageKind.banner,
        fileName: 'a.png',
        bytes: Uint8List(1),
      );

      expect(failure?.reason, ProfileImageFailureReason.tooLarge);
      expect(viewModel.state.uploading, isEmpty);
      expect(viewModel.state.user, UserModel.guest);
    });
  });
}
