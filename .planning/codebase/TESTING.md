# Testing Patterns

**Analysis Date:** 2025-01-17

## Test Framework

**Runner:**
- `flutter_test` - Built-in Flutter testing framework
- Config: `test/` directory at project root
- No explicit test config file (uses defaults)

**Assertion Library:**
- Built-in Flutter test matchers and assertions
- Common matchers: `expect()`, `isTrue`, `isFalse`, `equals()`, `throwsA()`, `isA<Type>()`, `returnsNormally`

**Run Commands:**
```bash
flutter test              # Run all tests
flutter test --watch     # Watch mode
flutter test --coverage  # Generate coverage report
flutter test path/to/test_file.dart  # Run specific test
```

## Test File Organization

**Location:**
- Mirror lib structure: Tests co-located in `test/` directory
- Example: `lib/features/authentication/data/repositories/auth_repository_impl.dart` has test at `test/features/authentication/data/repositories/auth_repository_impl_test.dart`
- Helper/utility tests: `test/helpers/`, `test/core/`
- Integration tests: `test/integration_test/`

**Naming:**
- Test file suffix: `_test.dart`
- Convention: `[ClassName]_test.dart`
- Examples: `safe_change_notifier_test.dart`, `auth_repository_impl_test.dart`, `signin_view_model_test.dart`

**Structure:**
```
test/
├── core/                           # Core layer tests
│   ├── base/
│   │   └── safe_change_notifier_test.dart
│   ├── network/
│   │   ├── dio_client_test.dart
│   │   ├── exceptions_test.dart
│   │   └── interceptors/
│   └── utils/
├── features/                       # Feature-specific tests
│   ├── authentication/
│   │   ├── data/
│   │   │   ├── data_sources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   └── use_cases/
│   │   └── presentation/
│   │       └── view_models/
│   └── books/
├── helpers/                        # Test utilities and setup
│   ├── pump_app.dart              # Widget tree test helper
│   └── test_injection.dart        # DI setup for tests
├── shared/
└── integration_test/               # Full app integration tests
```

## Test Structure

**Suite Organization:**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/authentication/domain/use_cases/auth_service.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthService authService;
  late MockAuthRepository mockAuthRepository;

  setUpAll(() {
    registerFallbackValue(AuthToken(token: ''));
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authService = AuthService(mockAuthRepository, mockAuthStorage);
  });

  group('AuthService', () {
    test('description of what is tested', () async {
      // arrange
      when(() => mockAuthRepository.method()).thenAnswer((_) async => value);
      
      // act
      final result = await authService.method();
      
      // assert
      expect(result, expectedValue);
      verify(() => mockAuthRepository.method()).called(1);
    });
  });
}
```

**Patterns:**
- Use `setUpAll()` for one-time setup (mock fallback values registration)
- Use `setUp()` for per-test initialization (create fresh mocks and objects)
- Use `group()` to organize related tests with descriptive strings
- Use `test()` for unit tests with descriptive names
- Follow Arrange-Act-Assert pattern with comments

## Mocking

**Framework:** `mocktail: ^1.0.4`

**Patterns:**
```dart
// Create mock class extending Mock
class MockAuthRepository extends Mock implements AuthRepository {}

// Set up behavior with when/thenAnswer
when(() => mockAuthRepository.signIn(any(), any()))
  .thenAnswer((_) async => AuthToken(token: 'access'));

// Verify calls
verify(() => mockAuthRepository.signIn('test@example.com', 'password')).called(1);

// Match any value
any()                          # Matches any value
any(named: 'paramName')        # Matches any named parameter
captureAny()                   # Capture argument for inspection
```

**Mock Creation Patterns:**
- Create mock for each dependency: `MockDio`, `MockAuthRepository`, `MockAuthService`
- Store mocks as late class variables: `late MockAuthRepository mockAuthRepository;`
- Initialize in setUp(): `mockAuthRepository = MockAuthRepository();`
- Register fallback values for custom types in setUpAll():
  ```dart
  setUpAll(() {
    registerFallbackValue(AuthToken(token: ''));
  });
  ```

**What to Mock:**
- External dependencies (repositories, services, data sources)
- Network clients: `Dio`, `DioClient`
- Storage/persistence: `AuthStorage`, `UserStorage`, `SettingsStorage`
- Other services: `AuthService`, `SettingsService`
- Always mock at feature boundaries

**What NOT to Mock:**
- Model/entity classes (use real instances or factories)
- Utility functions (execute real code)
- Local state variables in the unit under test
- Business logic being tested (test the real implementation)

## Fixtures and Factories

**Test Data:**
```dart
// Defined as final variables at top level in test file
final tToken = AuthToken(token: 'access');
final responseData = {'access_token': 'access'};
final bookListJson = {
  'data': [{'id': '1', 'title': 'Book 1'}],
  'metadata': {'total': 1, 'page': 1, 'limit': 20, 'lastPage': 1},
};

// Created fresh for each test or shared when immutable
```

**Response Mocking Pattern:**
```dart
// Create Response objects with required fields
Response(
  data: responseData,
  statusCode: 200,
  requestOptions: RequestOptions(path: ApiConstants.signIn),
)
```

**Location:**
- Inline in test file (no external fixture files)
- Define constants at top of test's main() function
- Create response objects within test methods

**Test Injection Setup:**
- Use `test/helpers/test_injection.dart` for DI setup
- Helper function `initTestDI()` allows customizing specific dependencies
- Default behavior provided for common mocks
- Example:
  ```dart
  await initTestDI(
    authService: mockAuthService,
    settingsService: mockSettingsService,
  );
  ```

## Coverage

**Requirements:** None enforced (no coverage threshold configured)

**View Coverage:**
```bash
flutter test --coverage
# Creates coverage/lcov.info report
```

## Test Types

**Unit Tests:**
- Scope: Single class or function in isolation
- Location: `test/features/`, `test/core/`
- Examples: Repository impl tests, ViewModel tests, Utility function tests
- Mocks all external dependencies
- Run fast (milliseconds)

**Integration Tests:**
- Scope: Multiple components working together
- Location: `test/integration_test/`
- Example: `test/integration_test/features/home/home_screen_test.dart`
- Tests real widget rendering, navigation, state management
- Uses `pumpApp()` helper from `test/helpers/pump_app.dart`
- Mocks services but tests real widget trees

**Widget/Screen Tests:**
- Scope: Individual screen/widget rendering and interaction
- Patterns: Use `WidgetTester` with `pumpApp()` extension
- Test tap interactions, state updates, navigation
- Verify UI renders correctly based on ViewModel state

## Common Patterns

**Async Testing:**
```dart
test('description', () async {
  when(() => mockService.method()).thenAnswer((_) async => result);
  
  final result = await viewModel.method();
  
  expect(result, expectedValue);
});
```

**Error Testing:**
```dart
test('throws exception on error', () async {
  when(() => mockRepository.method()).thenThrow(
    DioException(
      requestOptions: RequestOptions(path: ''),
      type: DioExceptionType.connectionTimeout,
    ),
  );

  expect(
    () => repository.method(),
    throwsA(isA<NetworkException>()),
  );
});
```

**State Change Testing (ViewModels):**
```dart
test('signIn success updates state correctly', () async {
  var notificationCount = 0;
  viewModel.addListener(() => notificationCount++);

  when(() => mockService.signIn(any(), any()))
    .thenAnswer((_) async => true);

  final result = await viewModel.signIn('test@example.com', 'password');

  expect(result, true);
  expect(viewModel.isLoading, false);
  expect(notificationCount, greaterThan(0));
});
```

**Widget Interaction Testing:**
```dart
testWidgets('submit button triggers signIn', (WidgetTester tester) async {
  await initTestDI(authService: mockAuthService);
  when(() => mockAuthService.signIn(any(), any()))
    .thenAnswer((_) async => true);

  await tester.pumpApp(SignInPage());
  
  // Enter email and password
  await tester.enterText(find.byType(TextField).first, 'test@example.com');
  await tester.enterText(find.byType(TextField).at(1), 'password');
  
  // Tap submit button
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();
  
  verify(() => mockAuthService.signIn('test@example.com', 'password')).called(1);
});
```

**SafeChangeNotifier Pattern Testing:**
```dart
test('should not throw when notifyListeners called after dispose', () {
  final viewModel = TestViewModel();
  
  viewModel.dispose();
  
  // This should not throw FlutterError
  expect(() => viewModel.testNotify(), returnsNormally);
});

test('should NOT notify listeners after dispose', () {
  final viewModel = TestViewModel();
  var notifiedCount = 0;
  
  viewModel.addListener(() => notifiedCount++);
  viewModel.dispose();
  viewModel.testNotify();
  
  expect(notifiedCount, equals(0));
});
```

## Test Coverage Analysis

**Core layer tests (`test/core/`):**
- SafeChangeNotifier: Full coverage of disposal safety
- Network exceptions: Comprehensive DioException mapping
- Interceptors: Auth, logging, cache behaviors
- JWT decoder: Token parsing and expiration

**Feature layer tests (`test/features/`):**
- Repositories: Response parsing, error handling, DioException mapping
- Services: State management, token handling, side effects
- ViewModels: State updates, listener notifications, error handling
- Data sources: Local storage operations
- Models: JSON serialization/deserialization

**Untested areas (identified):**
- UI components (organisms, molecules, atoms) - partially tested
- Full widget tree navigation flows - only integration test coverage
- Complex filtering logic (BookFilter) - exists but coverage unclear
- Real API integration - not tested (API mocked)

---

*Testing analysis: 2025-01-17*
