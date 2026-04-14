# Coding Conventions

**Analysis Date:** 2025-01-17

## Naming Patterns

**Files:**
- PascalCase for class names that map directly to file names: `SignInViewModel.dart`, `AuthRepositoryImpl.dart`, `SafeChangeNotifier.dart`
- snake_case for utility/helper files: `jwt_decoder.dart`, `api_constants.dart`, `app_localizations.dart`
- snake_case for feature/directory organization: `auth_response`, `secure_cookie_storage`, `logging_interceptor`

**Classes:**
- PascalCase for all class names: `AuthService`, `BooksViewModel`, `SignInPage`
- Suffix `Impl` for concrete implementations: `AuthRepositoryImpl`, `BooksRepositoryImpl`
- Service suffix for business logic classes: `AuthService`, `SettingsService`, `UserService`
- ViewModel suffix for presentation layer state managers: `SignInViewModel`, `BooksViewModel`, `HomeViewModel`
- Exception suffix for custom exceptions: `NetworkException`, `ServerException`, `AuthException`, `ValidationException`
- Use abstract class pattern for base types: `abstract class AppExceptions`, `abstract class SafeChangeNotifier`

**Functions:**
- camelCase for function names: `fetchBooks()`, `signIn()`, `refreshToken()`, `notifyListeners()`
- Private functions prefixed with underscore: `_initAuth()`, `_onViewModelChanged()`, `_handleSignIn()`
- Getter/setter using get/set keywords: `bool get isAuthenticated => _isAuthenticated;`, `String? get errorMessage => _errorMessage;`

**Variables:**
- camelCase for public variables: `isLoading`, `errorMessage`, `currentUser`
- Private variables prefixed with underscore: `_isAuthenticated`, `_token`, `_isDisposed`, `_layoutMode`
- Constants use camelCase with `const` keyword: `const String _logTag = 'AuthService'`
- Use `late` keyword for late-initialized properties in State classes: `late final SignInViewModel _viewModel;`

**Enums:**
- PascalCase enum name: `enum BooksLayoutMode { grid, list }`
- Lowercase enum values: `BooksLayoutMode.grid`, `BooksLayoutMode.list`

**Type Parameters:**
- Use meaningful names for generic types, not single letters where context is important
- Example: `Map<String, dynamic>` for JSON data, `Future<AuthToken>` for async operations

## Code Style

**Formatting:**
- No formatter explicitly configured (flutter_lints included)
- Single quotes for string literals: `'Debug mode'`, `'INFO'`
- Trailing commas required (enforced by linter rule `require_trailing_commas`)
- Proper indentation: 2 spaces for nested code

**Linting:**
- Tool: `flutter_lints: ^6.0.0` 
- Key rules enforced:
  - `prefer_double_quotes: false` - Use single quotes
  - `always_declare_return_types: true` - All functions must have explicit return types
  - `cancel_subscriptions: true` - Must cancel stream subscriptions
  - `close_sinks: true` - Must close sinks
  - `avoid_print: true` - Use logging instead of print()
  - `require_trailing_commas: true` - Trailing commas for multi-line constructs
  - `sort_child_properties_last: true` - Child widget parameter comes last

**Strict Analysis:**
- `strict-casts: true` - All type casts must be explicit
- `strict-inference: true` - Type inference must be unambiguous
- `strict-raw-types: true` - Raw generic types not allowed
- Generated files excluded: `**/*.g.dart`, `**/*.freezed.dart`

## Import Organization

**Order:**
1. Dart imports (`dart:` namespace first)
2. Flutter imports (`package:flutter/`)
3. Third-party package imports (`package:...`)
4. Local/relative imports (`../`, `./`)

**Path Aliases:**
- Relative paths used throughout: `import '../../../../core/logging/logger.dart'`
- No path aliases defined; use full relative paths
- Project-level imports use full package name: `import 'package:gatuno/core/di/injection.dart'`

**Barrel Files:**
- Used sparingly
- Example: `export '../../features/authentication/exceptions/exceptions.dart';` in network exceptions

## Error Handling

**Patterns:**
- Custom exception hierarchy rooted at `AppExceptions` base class in `lib/core/exceptions/exceptions.dart`
- Feature-specific exceptions in feature folders: `lib/features/authentication/exceptions/exceptions.dart`
- Network exceptions handled centrally: `ApiExceptionHandler.handle(DioException)` in `lib/core/network/exceptions.dart`
- HTTP status codes mapped to specific exceptions:
  ```dart
  case 400: return ValidationException(...)
  case 401: return UnauthorizedException(...)
  case 403: return AuthException(...)
  case 500: return ServerException(...)
  ```
- Always catch and rethrow `AppExceptions` to preserve custom error context
- Catch-all try-catch blocks at service/repository boundaries with logging

**Exception Flow:**
- Repository layer catches DioException and maps to AppExceptions
- Service layer catches both repository exceptions and unexpected errors
- ViewModel layer catches all exceptions, converts to user-facing error messages
- UI layer displays errors via SnackBar or similar

## Logging

**Framework:** `dart:developer` with `dev.log()` for all logging

**Log Levels:**
- `AppLogger.d()` - Debug messages
- `AppLogger.i()` - Info messages (most common for state changes)
- `AppLogger.w()` - Warning messages
- `AppLogger.e()` - Error messages with optional error object and stackTrace

**Patterns:**
- Every class with logging defines static `_logTag`: `static const String _logTag = 'AuthService'`
- Pass log tag as second parameter to all AppLogger calls: `AppLogger.i('message', _logTag)`
- Include context in messages: `'SignIn attempt for: $redactedEmail'`, `'Fetching books: page=${_options.page}'`
- Use `AppLogger.redactEmail()` to mask PII in logs when not in debug mode
- Log state transitions explicitly: `'SignIn success for: $redactedEmail'`
- Include error details for exceptions: `'SignUp DioException: ${e.message}'`

## Comments

**When to Comment:**
- Comments reserved for explaining WHY, not WHAT (code should be self-documenting)
- TODO comments used sparingly for future work: `// TODO: Implement proper tag selection`
- Comments used to explain complex logic or business rules, not obvious code
- Example: `// If logout fails on backend (e.g. token expired), we still want to log it but the service will still clear local tokens`

**JSDoc/TSDoc:**
- Dart documentation comments using triple slash: `/// A [ChangeNotifier] that safely handles [notifyListeners] calls after disposal.`
- Used for abstract classes, public APIs, and complex methods
- Document parameters and return values: `/// Returns true if the object has been disposed.`
- Use markdown-style links: `[ChangeNotifier]`, `[notifyListeners]`

## Function Design

**Size:**
- Functions should be focused and single-responsibility
- Async operations wrapped in try-catch blocks at service/repository boundaries
- Example service method handles full lifecycle: input validation → repository call → error handling → state notification

**Parameters:**
- Prefer named parameters for clarity: `getBooks({bool refresh = false, bool resetPage = true})`
- Use required keyword for mandatory parameters: `required BooksRepository repository`
- Use nullable types with `?` when parameter is optional: `String? name`
- Position required parameters before optional ones

**Return Values:**
- Always declare return type explicitly (enforced by linting)
- Use `Future<T>` for async operations
- Use `void` for functions that don't return values
- Return `bool` for success/failure in business logic: `Future<bool> signIn(String email, String password)`
- Return entity objects from repositories, never DTOs at caller's request

## Module Design

**Exports:**
- Centralized exception exports in network layer:
  ```dart
  export '../../features/authentication/exceptions/exceptions.dart';
  export '../exceptions/exceptions.dart';
  ```
- Feature-level exports used to expose public APIs

**Feature Structure:**
- Each feature organized as: `domain/`, `data/`, `presentation/`
- `domain/` contains abstract interfaces and entities (public contracts)
- `data/` contains implementations, models, data sources
- `presentation/` contains screens, view models, components
- Dependency flow: presentation → domain → data (never cross-layer)

**Layer Separation:**
- **Domain Layer:** Interfaces only (abstract repositories), entities, use cases/services
- **Data Layer:** Concrete implementations, models (with fromJson/toJson), data sources
- **Presentation Layer:** StatefulWidget/StatelessWidget screens, ViewModels extending SafeChangeNotifier
- **Core Layer:** Shared utilities, logging, DI, network, exceptions, theme

**View Model Pattern:**
- All view models extend `SafeChangeNotifier`
- ViewModels hold UI state: `_isLoading`, `_errorMessage`, `_data`
- ViewModels expose state via getters: `bool get isLoading => _isLoading`
- ViewModels have action methods that update state: `Future<bool> signIn(String email, String password)`
- State changes trigger `notifyListeners()` for UI rebuild
- ViewModels added as listeners in State's initState and removed in dispose

**Dependency Injection:**
- Uses `get_it: ^9.2.1` service locator
- DI setup in `lib/core/di/injection.dart` with `Future<void> initDI()` function
- Feature-level DI in feature folders: `authentication_injection.dart`, `books_injection.dart`
- Services registered as lazy singletons: `sl.registerLazySingleton<Service>(() => Service())`
- Repositories injected into services via constructor

## Constants and Configuration

**API Constants:**
- Centralized in `lib/core/network/api_constants.dart`
- Define endpoints as static const strings

**Theme and Design:**
- Custom theme colors in `lib/core/theme/theme.dart` using `ThemeExtension`
- Material Design 3 with custom color scheme
- Custom fonts defined in pubspec.yaml (Inknut Antiqua)

---

*Convention analysis: 2025-01-17*
