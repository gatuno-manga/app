# Architecture

**Analysis Date:** 2025-01-17

## Pattern Overview

**Overall:** Clean Architecture with MVVM (Model-View-ViewModel) + Provider for state management

**Key Characteristics:**
- Layered separation: Domain (business logic) → Data (repositories) → Presentation (UI)
- Feature-first organization with cross-cutting core services
- Dependency injection via GetIt for loose coupling
- Provider + ChangeNotifier for reactive state management
- GoRouter for declarative navigation with nested routes

## Layers

**Domain Layer:**
- Purpose: Define business logic contracts and entities (pure Dart, no Flutter dependencies)
- Location: `lib/features/{feature}/domain/`
- Contains: Abstract repositories, entities, use cases/services, domain exceptions
- Depends on: Nothing (pure business logic)
- Used by: Data layer, Presentation layer

**Data Layer:**
- Purpose: Implement domain repositories and handle external data sources
- Location: `lib/features/{feature}/data/`
- Contains: Repository implementations, models (JSON serialization), local/remote data sources
- Depends on: Domain layer, Core network services
- Used by: Domain layer contracts, Presentation layer

**Presentation Layer:**
- Purpose: Handle UI rendering and user interactions
- Location: `lib/features/{feature}/presentation/`
- Contains: Screens/Pages (widgets), ViewModels (state/logic), Components (atomic design)
- Depends on: Domain repositories, Core services, Domain entities
- Used by: Router

**Core Layer:**
- Purpose: Shared infrastructure and cross-cutting concerns
- Location: `lib/core/`
- Contains: DI setup, network client, logging, routing, exceptions, base classes, utilities
- Depends on: Nothing (foundational)
- Used by: All other layers

**Shared Layer:**
- Purpose: Reusable UI components and utilities
- Location: `lib/shared/`
- Contains: Atomic design components (atoms, molecules, organisms), validators, utilities
- Depends on: Core
- Used by: Features

## Data Flow

**Authentication Flow (SignIn Example):**

1. User enters credentials in UI (SignInPage)
2. SignInPage calls SignInViewModel.signIn(email, password)
3. SignInViewModel sets loading=true, calls AuthService.signIn()
4. AuthService (use case) calls AuthRepository.signIn(email, password)
5. AuthRepositoryImpl makes HTTP request via DioClient.dio.post()
6. Response converted to AuthResponse model, returned as AuthToken entity
7. AuthService stores token in AuthStorage (secure storage), sets _isAuthenticated=true
8. AuthService notifies listeners (ChangeNotifier)
9. SignInViewModel notifies listeners, returns success
10. GoRouter redirects to home based on AuthService.authenticated status
11. AuthInterceptor attaches token to all subsequent requests

**Books List Load Flow:**

1. BooksPage loaded, calls BooksViewModel.fetchBooks()
2. BooksViewModel sets isLoading=true, calls BooksRepository.getBooks(options)
3. BooksRepositoryImpl makes GET request with pagination/filter params
4. Response deserialized to BookListModel (contains list of BookModel)
5. BookListModel mapped to BookList entity (containing Book entities)
6. BooksViewModel stores bookList, sets isLoading=false
7. BooksViewModel notifies listeners
8. BooksPage rebuilds with BookGrid or BookList component
9. Pagination handled: scrolling triggers nextPage, rebuilds grid

**State Management:**
- AuthService extends ChangeNotifier, holds global auth state (_isAuthenticated, _token)
- Each feature has a ViewModel extending SafeChangeNotifier (handles post-dispose notifications)
- Components listen to ViewModels via Provider.of<ViewModel>(context)
- Reactive updates cascade: Service → ViewModel → Widget rebuild

## Key Abstractions

**Repository Pattern:**
- Purpose: Isolate data sources from business logic
- Examples: `lib/features/authentication/domain/repositories/auth_repository.dart`, `lib/features/books/domain/repositories/books_repository.dart`
- Pattern: Abstract class with methods, implemented by concrete classes in data layer, registered in DI

**Entity vs Model:**
- Entities: Pure domain objects (no serialization logic) in `domain/entities/`
- Models: Data transfer objects with fromJson/toJson in `data/models/`
- Conversion: Models → Entities before returning from Repository

**ChangeNotifier + Provider:**
- ViewModels extend SafeChangeNotifier (wrapper preventing post-dispose notifications)
- Registered globally via ChangeNotifierProvider or locally
- Listeners subscribe via context.read/watch
- notifyListeners() triggers rebuilds

**Page Options Pattern:**
- Immutable classes (copyWith) for pagination/filtering
- Examples: `BookPageOptions`, `ChapterPageOptions`
- Used to build query parameters for API calls

## Entry Points

**Main App Entry:**
- Location: `lib/main.dart`
- Triggers: Flutter engine on app startup
- Responsibilities:
  1. Calls initDI() to bootstrap dependency injection
  2. Loads SettingsService to determine initial route (/welcome or /home)
  3. Creates GoRouter with initial location
  4. Wraps app in MultiProvider (AuthService, SettingsService as globals)
  5. Launches MaterialApp.router with AppTheme, localizations, router config

**Router Configuration:**
- Location: `lib/router.dart`
- Creates GoRouter with StatefulShellRoute for bottom navigation
- Routes split into branches: homeBranch, booksBranch, settingsBranch
- Auth routes (/auth/signin, /auth/signup) via authRoutes list
- Welcome route (/welcome) via welcomeRoutes list
- Error handling: ErrorScreen for navigation failures

**Feature Routers:**
- Examples: `lib/features/authentication/auth_router.dart`, `lib/features/books/books_router.dart`
- Each feature defines its GoRoute(s) and branches
- Nested routes: `/books` → `/books/:bookId` (book detail nested within books branch)
- ViewModels injected via ChangeNotifierProvider at route builder

**DI Initialization:**
- Location: `lib/core/di/injection.dart`
- Order: Core services → Feature services → Interceptor setup
- Each feature has initAuthenticationInjection(), initBooksInjection(), etc.
- Services registered as lazy singletons (created on first access)

## Error Handling

**Strategy:** Exception hierarchy with specific types for different failure modes

**Patterns:**
- Base class AppExceptions in `lib/core/exceptions/exceptions.dart`
- Feature-specific subclasses: AuthException, UnauthorizedException in `lib/features/authentication/exceptions/exceptions.dart`
- Network exceptions: NetworkException, ServerException, ValidationException in `lib/core/network/exceptions.dart`
- API exception handler in ApiExceptionHandler.handle(DioException) maps HTTP status codes to specific exceptions
- ViewModels catch exceptions, set _errorMessage, return false/null
- Screens display error via error property (shown in SnackBars or error views)
- Token refresh failure triggers automatic logout (AuthService.performTokenRefresh)

## Cross-Cutting Concerns

**Logging:**
- Framework: Custom AppLogger singleton in `lib/core/logging/logger.dart`
- Approach: Methods for i (info), d (debug), w (warn), e (error) with redaction for sensitive data
- Tag parameter: All logs include feature/module identifier for filtering

**Validation:**
- Validators: EmailValidator, PasswordValidator in `lib/shared/validators/`
- Usage: ViewModels validate input before sending to API
- Messages: Localized validation error messages via l10n

**Authentication:**
- Token storage: Secure storage via flutter_secure_storage in AuthStorage
- Token refresh: JWT decoder checks expiration, AuthInterceptor handles 401 with atomic refresh
- Guards: GoRouter routes check AuthService.authenticated before navigation
- Interceptor: Attaches Bearer token to API requests, handles concurrent refreshes

**Network Caching:**
- Interceptor: Dio cache interceptor in `lib/core/network/interceptors/cache_interceptor.dart`
- Strategy: Cache GET requests with TTL, stores to file system
- Bypass: Cache-Control headers respected, manual refresh available

**Cookies:**
- Management: DIO cookie manager + jar for automatic cookie handling
- Storage: Secure cookie storage in `lib/core/network/cookies/secure_cookie_storage.dart`
- Interceptor: Automatic attach/retrieve via cookie_jar

---

*Architecture analysis: 2025-01-17*
