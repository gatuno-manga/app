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
class MockReadingProgressCoordinator extends Mock implements ReadingProgressCoordinator {}

void main() {
  late HomeViewModel viewModel;
  late MockAuthService mockAuthService;
  late MockUserService mockUserService;
  late MockBooksRepository mockBooksRepository;
  late MockReadingProgressCoordinator mockReadingCoordinator;

  setUpAll(() {
    registerFallbackValue(const BookPageOptions());
  });

  setUp(() {
    mockAuthService = MockAuthService();
    mockUserService = MockUserService();
    mockBooksRepository = MockBooksRepository();
    mockReadingCoordinator = MockReadingProgressCoordinator();

    when(() => mockAuthService.addListener(any())).thenAnswer((_) {});
    when(() => mockAuthService.removeListener(any())).thenAnswer((_) {});
    when(() => mockAuthService.authenticated).thenReturn(false);
    when(() => mockAuthService.isInitialized).thenReturn(true);
    when(
      () => mockUserService.getCurrentUser(),
    ).thenAnswer((_) async => UserModel.guest);
    
    when(() => mockBooksRepository.getBooks(any())).thenAnswer((_) async => const BookList(data: [], total: PositiveInt(0), page: PositiveInt(1), limit: PositiveInt(12), totalPages: PositiveInt(1)));
    when(() => mockReadingCoordinator.getContinueReadingBooks(limit: any(named: 'limit'))).thenAnswer((_) async => []);

    viewModel = HomeViewModel(mockAuthService, mockUserService, mockBooksRepository, mockReadingCoordinator);
  });

  group('HomeViewModel', () {
    test('should reflect auth status from service', () {
      expect(viewModel.isAuthenticated, isFalse);
      expect(viewModel.isInitialized, isTrue);
    });

    test('should load user when authenticated', () async {
      final user = UserModel(
        id: const UserId('1'),
        email: const UserEmail('test@example.com'),
        roles: const UserRoles(['user']),
        maxWeightSensitiveContent: const SensitiveContentWeight(5),
        name: const UserDisplayName('Test'),
      );

      when(() => mockAuthService.authenticated).thenReturn(true);
      when(
        () => mockUserService.getCurrentUser(),
      ).thenAnswer((_) async => user);

      // Re-initialize to trigger _loadUser
      viewModel = HomeViewModel(mockAuthService, mockUserService, mockBooksRepository, mockReadingCoordinator);

      // Wait for async load
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.isAuthenticated, isTrue);
      expect(viewModel.displayName, equals('Test'));
    });

    test('displayName should be null when not authenticated', () {
      expect(viewModel.displayName, isNull);
    });
  });
}
