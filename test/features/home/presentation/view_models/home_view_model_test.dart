import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gatuno/features/home/presentation/view_models/home_view_model.dart';
import 'package:gatuno/features/authentication/domain/use_cases/auth_service.dart';
import 'package:gatuno/features/users/domain/use_cases/user_service.dart';
import 'package:gatuno/features/users/data/models/user_model.dart';
import 'package:gatuno/features/users/domain/value_objects/user_id.dart';
import 'package:gatuno/features/users/domain/value_objects/user_email.dart';
import 'package:gatuno/features/users/domain/value_objects/user_roles.dart';
import 'package:gatuno/features/users/domain/value_objects/sensitive_content_weight.dart';
import 'package:gatuno/features/users/domain/value_objects/user_display_name.dart';
import 'package:gatuno/features/books/domain/repositories/books_repository.dart';
import 'package:gatuno/features/books/domain/entities/book.dart';
import 'package:gatuno/features/books/domain/entities/book_page_options.dart';
import 'package:gatuno/features/reading/domain/use_cases/reading_progress_coordinator.dart';
import 'package:gatuno/shared/domain/value_objects/positive_int.dart';

class MockAuthService extends Mock implements AuthService {}

class MockUserService extends Mock implements UserService {}

class MockBooksRepository extends Mock implements BooksRepository {}

class MockReadingProgressCoordinator extends Mock
    implements ReadingProgressCoordinator {}

void main() {
  late HomeViewModel viewModel;
  late MockAuthService mockAuthService;
  late MockUserService mockUserService;
  late MockBooksRepository mockBooksRepository;
  late MockReadingProgressCoordinator mockReadingCoordinator;

  setUpAll(() {
    registerFallbackValue(const BookPageOptions());
  });

  UserModel user({String? name, String? imageUrl}) => UserModel(
    id: const UserId('1'),
    email: const UserEmail('test@example.com'),
    roles: const UserRoles(['user']),
    maxWeightSensitiveContent: const SensitiveContentWeight(5),
    name: name == null ? null : UserDisplayName(name),
    profilePictureUrl: imageUrl,
  );

  HomeViewModel buildViewModel() => HomeViewModel(
    mockAuthService,
    mockUserService,
    mockBooksRepository,
    mockReadingCoordinator,
  );

  setUp(() {
    mockAuthService = MockAuthService();
    mockUserService = MockUserService();
    mockBooksRepository = MockBooksRepository();
    mockReadingCoordinator = MockReadingProgressCoordinator();

    when(
      () => mockAuthService.authStateStream,
    ).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthService.authenticated).thenReturn(false);
    when(() => mockAuthService.isInitialized).thenReturn(true);
    when(
      () => mockUserService.profileStream,
    ).thenAnswer((_) => Stream.value(UserModel.guest));

    when(() => mockBooksRepository.getBooks(any())).thenAnswer(
      (_) async => const BookList(
        data: [],
        total: PositiveInt(0),
        page: PositiveInt(1),
        limit: PositiveInt(12),
        totalPages: PositiveInt(1),
      ),
    );
    when(
      () => mockReadingCoordinator.getContinueReadingBooks(
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => []);

    viewModel = buildViewModel();
  });

  group('HomeViewModel', () {
    test('should reflect auth status from service', () {
      expect(viewModel.state.isAuthenticated, isFalse);
      expect(viewModel.state.isInitialized, isTrue);
    });

    test('starts with the guest user', () {
      expect(viewModel.state.user, same(UserModel.guest));
    });

    test('takes the user from the profile stream', () async {
      when(() => mockAuthService.authenticated).thenReturn(true);
      when(() => mockUserService.profileStream).thenAnswer(
        (_) => Stream.value(user(name: 'Test', imageUrl: 'http://x/1.webp')),
      );

      viewModel = buildViewModel();
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.isAuthenticated, isTrue);
      expect(viewModel.state.user.displayName, 'Test');
      expect(viewModel.state.user.profilePictureUrl, 'http://x/1.webp');
    });

    test('follows later profile changes', () async {
      final profiles = StreamController<UserModel>();
      addTearDown(profiles.close);
      when(
        () => mockUserService.profileStream,
      ).thenAnswer((_) => profiles.stream);
      viewModel = buildViewModel();

      profiles.add(user(name: 'Fresh', imageUrl: 'http://x/new.webp'));
      await Future<void>.delayed(Duration.zero);
      expect(viewModel.state.user.profilePictureUrl, 'http://x/new.webp');

      profiles.add(UserModel.guest);
      await Future<void>.delayed(Duration.zero);
      expect(viewModel.state.user, same(UserModel.guest));
    });
  });
}
