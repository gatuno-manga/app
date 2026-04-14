<!-- GSD:project-start source:PROJECT.md -->
## Project

**Gatuno**

Gatuno e um aplicativo mobile em Flutter para descoberta e consumo de conteudo de livros, com autenticacao, perfil de usuario e configuracoes da aplicacao. O projeto ja possui base funcional em producao de desenvolvimento (navegacao, auth, listagem e detalhes) e agora evolui para fortalecer o fluxo de entrega. O foco imediato e automatizar CI/CD para gerar artefatos de release quando uma nova versao for publicada.

**Core Value:** Toda nova versao marcada no repositorio deve gerar automaticamente artefatos de app anexados em uma GitHub Release, de forma previsivel e repetivel.

### Constraints

- **CI/CD**: Deve usar GitHub Actions — padrao escolhido para a automacao
- **Trigger**: Execucao somente em push de tag semantica (`vX.Y.Z`) — alinhado ao fluxo de versionamento
- **Plataformas**: Android e iOS devem ser contemplados — requisito explicito do usuario
- **Assinatura**: Sem segredos/certificados por enquanto, logo o pipeline precisa suportar artefatos sem assinatura — evita bloqueio imediato
- **Escopo de entrega**: Apenas gerar e anexar artefatos na release — publicacao em stores fica para fase futura
<!-- GSD:project-end -->

<!-- GSD:stack-start source:codebase/STACK.md -->
## Technology Stack

## Languages
- Dart 3.11.1+ - Cross-platform mobile application development
- Used throughout `lib/` directory for all application logic
- Kotlin/Swift - Platform-specific code in `android/` and `ios/` directories
- YAML - Configuration files (`pubspec.yaml`, `analysis_options.yaml`, `l10n.yaml`)
## Runtime
- Flutter SDK (linked to Dart 3.11.1)
- Dart VM for development and testing
- Pub (Dart package manager)
- Lockfile: `pubspec.lock` (present)
## Frameworks
- Flutter 3.x - Cross-platform mobile UI framework
- Material Design 3 - UI component library
- Provider 6.1.2 - Consumer-based state management
- GetIt 9.2.1 - Service locator for dependency injection
- go_router 17.1.0 - Declarative routing and navigation
- Dio 5.9.2 - HTTP client with advanced features
- dio_cache_interceptor 4.0.0 - HTTP request caching layer
- cookie_jar 4.0.8 - Cookie storage and management
- dio_cookie_manager 3.1.2 - Cookie interceptor for Dio
- flutter_secure_storage 10.0.0 - Platform-native secure credential storage
- flutter_localizations (SDK) - Flutter localization support
- intl 0.20.2 - Internationalization library
- Custom app localizations with `AppLocalizations` delegate
- Supported locales: English (en), Portuguese (pt)
- path_provider 2.1.5 - Access to application directories (cache, documents, etc.)
- http_cache_file_store 2.0.1 - File-based HTTP cache storage
- email_validator 3.0.0 - Email validation utility
- optional 6.1.0+1 - Optional type handling
- cupertino_icons 1.0.8 - iOS-style icon set
- flutter_test (SDK) - Flutter testing framework
- mocktail 1.0.4 - Mocking library for unit tests
- Test files co-located with feature modules (e.g., `test/core/`, `test/features/`)
- flutter_launcher_icons 0.14.4 - App icon generation
- flutter_lints 6.0.0 - Flutter lint rules
## Key Dependencies
- Dio 5.9.2 - Central to all HTTP communication
- Provider 6.1.2 - Synchronizes app state across UI
- flutter_secure_storage 10.0.0 - Stores authentication tokens securely
- go_router 17.1.0 - Enables complex nested navigation with deep linking
- GetIt 9.2.1 - Manages dependency resolution and lifecycle
## Configuration
- Variables configured via `.env` file (see `.env.example`)
- Critical variable: `API_BASE_URL` - REST API endpoint
- Default development URL: `http://localhost:3000`
- Base URL is configurable at runtime via `SettingsService`
- `pubspec.yaml` - Main dependency and Flutter configuration
- `analysis_options.yaml` - Linter rules and analysis settings
- `l10n.yaml` - Internationalization configuration (lines 1-10)
- Supported locales configured in `main.dart` (line 49)
- `flutter: generate: true` - Enables automatic code generation
- Excludes generated files from analysis: `*.g.dart`, `*.freezed.dart`
- Generated localizations in `lib/l10n/app_localizations.dart`
## Platform Requirements
- Dart SDK 3.11.1+
- Flutter SDK (compatible with Dart 3.11.1)
- Android SDK (minimum API 21, configured in launcher icons)
- Xcode (for iOS development)
- Java OpenJDK 17.0.2 (for Android build tools)
- Target: Android (minimum API 21) and iOS
- Self-signed certificate support enabled for local network API servers
- HTTP client adapter: `IOHttpClientAdapter` for certificate management
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->
## Conventions

## Naming Patterns
- PascalCase for class names that map directly to file names: `SignInViewModel.dart`, `AuthRepositoryImpl.dart`, `SafeChangeNotifier.dart`
- snake_case for utility/helper files: `jwt_decoder.dart`, `api_constants.dart`, `app_localizations.dart`
- snake_case for feature/directory organization: `auth_response`, `secure_cookie_storage`, `logging_interceptor`
- PascalCase for all class names: `AuthService`, `BooksViewModel`, `SignInPage`
- Suffix `Impl` for concrete implementations: `AuthRepositoryImpl`, `BooksRepositoryImpl`
- Service suffix for business logic classes: `AuthService`, `SettingsService`, `UserService`
- ViewModel suffix for presentation layer state managers: `SignInViewModel`, `BooksViewModel`, `HomeViewModel`
- Exception suffix for custom exceptions: `NetworkException`, `ServerException`, `AuthException`, `ValidationException`
- Use abstract class pattern for base types: `abstract class AppExceptions`, `abstract class SafeChangeNotifier`
- camelCase for function names: `fetchBooks()`, `signIn()`, `refreshToken()`, `notifyListeners()`
- Private functions prefixed with underscore: `_initAuth()`, `_onViewModelChanged()`, `_handleSignIn()`
- Getter/setter using get/set keywords: `bool get isAuthenticated => _isAuthenticated;`, `String? get errorMessage => _errorMessage;`
- camelCase for public variables: `isLoading`, `errorMessage`, `currentUser`
- Private variables prefixed with underscore: `_isAuthenticated`, `_token`, `_isDisposed`, `_layoutMode`
- Constants use camelCase with `const` keyword: `const String _logTag = 'AuthService'`
- Use `late` keyword for late-initialized properties in State classes: `late final SignInViewModel _viewModel;`
- PascalCase enum name: `enum BooksLayoutMode { grid, list }`
- Lowercase enum values: `BooksLayoutMode.grid`, `BooksLayoutMode.list`
- Use meaningful names for generic types, not single letters where context is important
- Example: `Map<String, dynamic>` for JSON data, `Future<AuthToken>` for async operations
## Code Style
- No formatter explicitly configured (flutter_lints included)
- Single quotes for string literals: `'Debug mode'`, `'INFO'`
- Trailing commas required (enforced by linter rule `require_trailing_commas`)
- Proper indentation: 2 spaces for nested code
- Tool: `flutter_lints: ^6.0.0` 
- Key rules enforced:
- `strict-casts: true` - All type casts must be explicit
- `strict-inference: true` - Type inference must be unambiguous
- `strict-raw-types: true` - Raw generic types not allowed
- Generated files excluded: `**/*.g.dart`, `**/*.freezed.dart`
## Import Organization
- Relative paths used throughout: `import '../../../../core/logging/logger.dart'`
- No path aliases defined; use full relative paths
- Project-level imports use full package name: `import 'package:gatuno/core/di/injection.dart'`
- Used sparingly
- Example: `export '../../features/authentication/exceptions/exceptions.dart';` in network exceptions
## Error Handling
- Custom exception hierarchy rooted at `AppExceptions` base class in `lib/core/exceptions/exceptions.dart`
- Feature-specific exceptions in feature folders: `lib/features/authentication/exceptions/exceptions.dart`
- Network exceptions handled centrally: `ApiExceptionHandler.handle(DioException)` in `lib/core/network/exceptions.dart`
- HTTP status codes mapped to specific exceptions:
- Always catch and rethrow `AppExceptions` to preserve custom error context
- Catch-all try-catch blocks at service/repository boundaries with logging
- Repository layer catches DioException and maps to AppExceptions
- Service layer catches both repository exceptions and unexpected errors
- ViewModel layer catches all exceptions, converts to user-facing error messages
- UI layer displays errors via SnackBar or similar
## Logging
- `AppLogger.d()` - Debug messages
- `AppLogger.i()` - Info messages (most common for state changes)
- `AppLogger.w()` - Warning messages
- `AppLogger.e()` - Error messages with optional error object and stackTrace
- Every class with logging defines static `_logTag`: `static const String _logTag = 'AuthService'`
- Pass log tag as second parameter to all AppLogger calls: `AppLogger.i('message', _logTag)`
- Include context in messages: `'SignIn attempt for: $redactedEmail'`, `'Fetching books: page=${_options.page}'`
- Use `AppLogger.redactEmail()` to mask PII in logs when not in debug mode
- Log state transitions explicitly: `'SignIn success for: $redactedEmail'`
- Include error details for exceptions: `'SignUp DioException: ${e.message}'`
## Comments
- Comments reserved for explaining WHY, not WHAT (code should be self-documenting)
- TODO comments used sparingly for future work: `// TODO: Implement proper tag selection`
- Comments used to explain complex logic or business rules, not obvious code
- Example: `// If logout fails on backend (e.g. token expired), we still want to log it but the service will still clear local tokens`
- Dart documentation comments using triple slash: `/// A [ChangeNotifier] that safely handles [notifyListeners] calls after disposal.`
- Used for abstract classes, public APIs, and complex methods
- Document parameters and return values: `/// Returns true if the object has been disposed.`
- Use markdown-style links: `[ChangeNotifier]`, `[notifyListeners]`
## Function Design
- Functions should be focused and single-responsibility
- Async operations wrapped in try-catch blocks at service/repository boundaries
- Example service method handles full lifecycle: input validation → repository call → error handling → state notification
- Prefer named parameters for clarity: `getBooks({bool refresh = false, bool resetPage = true})`
- Use required keyword for mandatory parameters: `required BooksRepository repository`
- Use nullable types with `?` when parameter is optional: `String? name`
- Position required parameters before optional ones
- Always declare return type explicitly (enforced by linting)
- Use `Future<T>` for async operations
- Use `void` for functions that don't return values
- Return `bool` for success/failure in business logic: `Future<bool> signIn(String email, String password)`
- Return entity objects from repositories, never DTOs at caller's request
## Module Design
- Centralized exception exports in network layer:
- Feature-level exports used to expose public APIs
- Each feature organized as: `domain/`, `data/`, `presentation/`
- `domain/` contains abstract interfaces and entities (public contracts)
- `data/` contains implementations, models, data sources
- `presentation/` contains screens, view models, components
- Dependency flow: presentation → domain → data (never cross-layer)
- **Domain Layer:** Interfaces only (abstract repositories), entities, use cases/services
- **Data Layer:** Concrete implementations, models (with fromJson/toJson), data sources
- **Presentation Layer:** StatefulWidget/StatelessWidget screens, ViewModels extending SafeChangeNotifier
- **Core Layer:** Shared utilities, logging, DI, network, exceptions, theme
- All view models extend `SafeChangeNotifier`
- ViewModels hold UI state: `_isLoading`, `_errorMessage`, `_data`
- ViewModels expose state via getters: `bool get isLoading => _isLoading`
- ViewModels have action methods that update state: `Future<bool> signIn(String email, String password)`
- State changes trigger `notifyListeners()` for UI rebuild
- ViewModels added as listeners in State's initState and removed in dispose
- Uses `get_it: ^9.2.1` service locator
- DI setup in `lib/core/di/injection.dart` with `Future<void> initDI()` function
- Feature-level DI in feature folders: `authentication_injection.dart`, `books_injection.dart`
- Services registered as lazy singletons: `sl.registerLazySingleton<Service>(() => Service())`
- Repositories injected into services via constructor
## Constants and Configuration
- Centralized in `lib/core/network/api_constants.dart`
- Define endpoints as static const strings
- Custom theme colors in `lib/core/theme/theme.dart` using `ThemeExtension`
- Material Design 3 with custom color scheme
- Custom fonts defined in pubspec.yaml (Inknut Antiqua)
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->
## Architecture

## Pattern Overview
- Layered separation: Domain (business logic) → Data (repositories) → Presentation (UI)
- Feature-first organization with cross-cutting core services
- Dependency injection via GetIt for loose coupling
- Provider + ChangeNotifier for reactive state management
- GoRouter for declarative navigation with nested routes
## Layers
- Purpose: Define business logic contracts and entities (pure Dart, no Flutter dependencies)
- Location: `lib/features/{feature}/domain/`
- Contains: Abstract repositories, entities, use cases/services, domain exceptions
- Depends on: Nothing (pure business logic)
- Used by: Data layer, Presentation layer
- Purpose: Implement domain repositories and handle external data sources
- Location: `lib/features/{feature}/data/`
- Contains: Repository implementations, models (JSON serialization), local/remote data sources
- Depends on: Domain layer, Core network services
- Used by: Domain layer contracts, Presentation layer
- Purpose: Handle UI rendering and user interactions
- Location: `lib/features/{feature}/presentation/`
- Contains: Screens/Pages (widgets), ViewModels (state/logic), Components (atomic design)
- Depends on: Domain repositories, Core services, Domain entities
- Used by: Router
- Purpose: Shared infrastructure and cross-cutting concerns
- Location: `lib/core/`
- Contains: DI setup, network client, logging, routing, exceptions, base classes, utilities
- Depends on: Nothing (foundational)
- Used by: All other layers
- Purpose: Reusable UI components and utilities
- Location: `lib/shared/`
- Contains: Atomic design components (atoms, molecules, organisms), validators, utilities
- Depends on: Core
- Used by: Features
## Data Flow
- AuthService extends ChangeNotifier, holds global auth state (_isAuthenticated, _token)
- Each feature has a ViewModel extending SafeChangeNotifier (handles post-dispose notifications)
- Components listen to ViewModels via Provider.of<ViewModel>(context)
- Reactive updates cascade: Service → ViewModel → Widget rebuild
## Key Abstractions
- Purpose: Isolate data sources from business logic
- Examples: `lib/features/authentication/domain/repositories/auth_repository.dart`, `lib/features/books/domain/repositories/books_repository.dart`
- Pattern: Abstract class with methods, implemented by concrete classes in data layer, registered in DI
- Entities: Pure domain objects (no serialization logic) in `domain/entities/`
- Models: Data transfer objects with fromJson/toJson in `data/models/`
- Conversion: Models → Entities before returning from Repository
- ViewModels extend SafeChangeNotifier (wrapper preventing post-dispose notifications)
- Registered globally via ChangeNotifierProvider or locally
- Listeners subscribe via context.read/watch
- notifyListeners() triggers rebuilds
- Immutable classes (copyWith) for pagination/filtering
- Examples: `BookPageOptions`, `ChapterPageOptions`
- Used to build query parameters for API calls
## Entry Points
- Location: `lib/main.dart`
- Triggers: Flutter engine on app startup
- Responsibilities:
- Location: `lib/router.dart`
- Creates GoRouter with StatefulShellRoute for bottom navigation
- Routes split into branches: homeBranch, booksBranch, settingsBranch
- Auth routes (/auth/signin, /auth/signup) via authRoutes list
- Welcome route (/welcome) via welcomeRoutes list
- Error handling: ErrorScreen for navigation failures
- Examples: `lib/features/authentication/auth_router.dart`, `lib/features/books/books_router.dart`
- Each feature defines its GoRoute(s) and branches
- Nested routes: `/books` → `/books/:bookId` (book detail nested within books branch)
- ViewModels injected via ChangeNotifierProvider at route builder
- Location: `lib/core/di/injection.dart`
- Order: Core services → Feature services → Interceptor setup
- Each feature has initAuthenticationInjection(), initBooksInjection(), etc.
- Services registered as lazy singletons (created on first access)
## Error Handling
- Base class AppExceptions in `lib/core/exceptions/exceptions.dart`
- Feature-specific subclasses: AuthException, UnauthorizedException in `lib/features/authentication/exceptions/exceptions.dart`
- Network exceptions: NetworkException, ServerException, ValidationException in `lib/core/network/exceptions.dart`
- API exception handler in ApiExceptionHandler.handle(DioException) maps HTTP status codes to specific exceptions
- ViewModels catch exceptions, set _errorMessage, return false/null
- Screens display error via error property (shown in SnackBars or error views)
- Token refresh failure triggers automatic logout (AuthService.performTokenRefresh)
## Cross-Cutting Concerns
- Framework: Custom AppLogger singleton in `lib/core/logging/logger.dart`
- Approach: Methods for i (info), d (debug), w (warn), e (error) with redaction for sensitive data
- Tag parameter: All logs include feature/module identifier for filtering
- Validators: EmailValidator, PasswordValidator in `lib/shared/validators/`
- Usage: ViewModels validate input before sending to API
- Messages: Localized validation error messages via l10n
- Token storage: Secure storage via flutter_secure_storage in AuthStorage
- Token refresh: JWT decoder checks expiration, AuthInterceptor handles 401 with atomic refresh
- Guards: GoRouter routes check AuthService.authenticated before navigation
- Interceptor: Attaches Bearer token to API requests, handles concurrent refreshes
- Interceptor: Dio cache interceptor in `lib/core/network/interceptors/cache_interceptor.dart`
- Strategy: Cache GET requests with TTL, stores to file system
- Bypass: Cache-Control headers respected, manual refresh available
- Management: DIO cookie manager + jar for automatic cookie handling
- Storage: Secure cookie storage in `lib/core/network/cookies/secure_cookie_storage.dart`
- Interceptor: Automatic attach/retrieve via cookie_jar
<!-- GSD:architecture-end -->

<!-- GSD:skills-start source:skills/ -->
## Project Skills

No project skills found. Add skills to any of: `.github/skills/`, `.agents/skills/`, `.cursor/skills/`, or `.github/skills/` with a `SKILL.md` index file.
<!-- GSD:skills-end -->

<!-- GSD:workflow-start source:GSD defaults -->
## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd-quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd-debug` for investigation and bug fixing
- `/gsd-execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->



<!-- GSD:profile-start -->
## Developer Profile

> Profile not yet configured. Run `/gsd-profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
