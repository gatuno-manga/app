# Codebase Structure

**Analysis Date:** 2025-01-17

## Directory Layout

```
lib/
├── main.dart                      # App entry point, DI initialization, MultiProvider setup
├── router.dart                    # GoRouter configuration with branches
├── core/                          # Cross-cutting infrastructure
│   ├── base/                      # Base classes (SafeChangeNotifier)
│   ├── di/                        # Dependency injection (GetIt setup)
│   ├── exceptions/                # App-level exception definitions
│   ├── logging/                   # AppLogger singleton
│   ├── network/                   # HTTP client, API constants, interceptors
│   │   ├── interceptors/          # Auth, cache, cookie, logging interceptors
│   │   └── cookies/               # Secure cookie storage
│   ├── router/                    # Router utilities (keys for navigation)
│   ├── theme/                     # AppTheme (light/dark themes)
│   └── utils/                     # JWT decoder, common utilities
├── features/                      # Feature modules (Clean Architecture)
│   ├── authentication/
│   │   ├── auth_router.dart       # Auth routes (/auth/signin, /auth/signup)
│   │   ├── authentication_injection.dart  # Feature DI
│   │   ├── domain/
│   │   │   ├── entities/          # AuthToken entity
│   │   │   ├── repositories/      # AuthRepository abstract
│   │   │   ├── use_cases/         # AuthService (extends ChangeNotifier)
│   │   │   └── exceptions/        # AuthException, UnauthorizedException
│   │   ├── data/
│   │   │   ├── data_sources/      # AuthStorage (secure storage)
│   │   │   ├── models/            # AuthResponse model (JSON serialization)
│   │   │   └── repositories/      # AuthRepositoryImpl (implements domain abstract)
│   │   └── presentation/
│   │       ├── view_models/       # SignInViewModel, SignUpViewModel
│   │       ├── views/             # SignInPage, SignUpPage (screens)
│   │       └── components/        # SignInForm, SignUpForm (organisms)
│   ├── books/
│   │   ├── books_router.dart      # Books routes (/books, /books/:bookId)
│   │   ├── books_injection.dart   # Feature DI
│   │   ├── domain/
│   │   │   ├── entities/          # Book, BookList, BookPageOptions, Chapter
│   │   │   ├── repositories/      # BooksRepository abstract
│   │   │   └── (no use_cases/)    # Repository called directly from VM
│   │   ├── data/
│   │   │   ├── data_sources/      # Remote data source (via repository)
│   │   │   ├── models/            # BookModel, ChapterModel (with fromJson/toJson)
│   │   │   └── repositories/      # BooksRepositoryImpl
│   │   └── presentation/
│   │       ├── view_models/       # BooksViewModel, BookDetailsViewModel
│   │       ├── views/             # BooksPage, BookDetailsPage
│   │       └── components/        # Organized by atomic design:
│   │           ├── atoms/         # BookCover, BookTitle, BookTag, etc.
│   │           ├── molecules/     # BookCard, BookInfo, ChapterTile, etc.
│   │           ├── organisms/     # BookGrid, BookList, BookAppBar, etc.
│   │           └── templates/     # BooksTemplate, BookDetailsTemplate (layout)
│   ├── users/
│   │   ├── users_router.dart
│   │   ├── users_injection.dart
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   ├── settings/
│   │   ├── settings_router.dart
│   │   ├── (no injection file/)
│   │   ├── domain/
│   │   │   ├── entities/          # SettingsEntity
│   │   │   ├── repositories/      # SettingsRepository abstract
│   │   │   └── use_cases/         # SettingsService (extends ChangeNotifier, global)
│   │   ├── data/
│   │   │   ├── data_sources/      # SettingsStorage (local data source)
│   │   │   └── repositories/      # SettingsRepositoryImpl
│   │   └── presentation/
│   ├── home/
│   │   ├── home_router.dart
│   │   ├── home_injection.dart
│   │   └── presentation/
│   ├── welcome/
│   │   ├── welcome_router.dart
│   │   └── presentation/
│   └── (other features follow same pattern)
├── shared/                        # Reusable components and utilities
│   ├── components/                # Shared UI components
│   │   ├── atoms/                 # AppButton, AppTextField, AppAvatar, etc.
│   │   ├── molecules/             # AppBottomNavBar, Pagination, etc.
│   │   └── organisms/             # NavigationShell (bottom nav container)
│   ├── icons/                     # Custom icon definitions
│   ├── presentation/
│   │   ├── error_screen.dart      # Global error fallback
│   │   └── view_models/           # NavigationViewModel
│   ├── utils/                     # Shared utilities (formatters, helpers)
│   └── validators/                # EmailValidator, PasswordValidator
├── l10n/                          # Localization
│   ├── app_en.arb
│   ├── app_pt.arb
│   └── app_localizations.dart     # Generated localizations
└── (generated files hidden)
```

## Directory Purposes

**`lib/core/`:**
- Purpose: Infrastructure, no business logic
- Contains: Network client, DI, logging, base classes, routing keys, theme
- Key files: `dio_client.dart`, `injection.dart`, `logger.dart`, `theme.dart`

**`lib/features/{feature}/domain/`:**
- Purpose: Business logic and contracts
- Contains: Entities (immutable data objects), abstract repositories, services/use cases
- Key files: `entities/*.dart`, `repositories/*.dart`, `use_cases/*.dart`

**`lib/features/{feature}/data/`:**
- Purpose: Data access implementation
- Contains: Repository implementations, models (DTOs), data sources (API/storage)
- Key files: `models/*.dart`, `repositories/*_impl.dart`, `data_sources/*.dart`

**`lib/features/{feature}/presentation/`:**
- Purpose: UI and state management for feature
- Contains: Screens, ViewModels, UI components
- Structure:
  - `views/`: Full screens (Pages, stateful widgets)
  - `view_models/`: Business logic for UI (extends ChangeNotifier)
  - `components/`: Reusable widgets organized by atomic design

**`lib/features/{feature}/presentation/components/`:**
- Purpose: Feature-specific UI components (atoms, molecules, organisms, templates)
- Atoms: Basic building blocks (buttons, text, images)
- Molecules: Combinations of atoms (cards, input groups)
- Organisms: Complex components (lists, forms, headers)
- Templates: Layout structures (scaffold builders)

**`lib/shared/`:**
- Purpose: App-wide reusable components and utilities
- Contains: Generic atoms/molecules/organisms, validators, utilities
- Not feature-specific; used across multiple features

## Key File Locations

**Entry Points:**
- `lib/main.dart`: App bootstrap, DI init, MultiProvider setup, creates GoRouter
- `lib/router.dart`: Global GoRouter creation with branch configuration

**Configuration:**
- `lib/core/network/api_constants.dart`: API endpoints
- `lib/core/theme/theme.dart`: Material themes (light/dark)
- `lib/l10n/app_*.arb`: Localization strings (English, Portuguese)
- `pubspec.yaml`: Dependencies and assets

**Core Infrastructure:**
- `lib/core/di/injection.dart`: GetIt service locator setup
- `lib/core/network/dio_client.dart`: HTTP client with certificate pinning
- `lib/core/logging/logger.dart`: Logging utility with email redaction
- `lib/core/network/interceptors/auth_interceptor.dart`: Token attachment and refresh

**Feature Example (Authentication):**
- Domain: `lib/features/authentication/domain/repositories/auth_repository.dart`
- Data: `lib/features/authentication/data/repositories/auth_repository_impl.dart`
- Use Case: `lib/features/authentication/domain/use_cases/auth_service.dart`
- ViewModel: `lib/features/authentication/presentation/view_models/signin_view_model.dart`
- Screen: `lib/features/authentication/presentation/views/signin_screen.dart`

**Feature Example (Books):**
- Domain: `lib/features/books/domain/repositories/books_repository.dart`
- ViewModel: `lib/features/books/presentation/view_models/books_view_model.dart`
- Screen: `lib/features/books/presentation/views/books_screen.dart`
- Components: `lib/features/books/presentation/components/{atoms,molecules,organisms,templates}/`

## Naming Conventions

**Files:**
- Screens: `{feature}_screen.dart` or `{action}_screen.dart` (e.g., `books_screen.dart`, `signin_screen.dart`)
- ViewModels: `{feature}_view_model.dart` or `{action}_view_model.dart` (e.g., `books_view_model.dart`, `signin_view_model.dart`)
- Models: `{entity}_model.dart` (e.g., `book_model.dart`, `auth_response.dart`)
- Entities: `{entity}.dart` (e.g., `book.dart`, `auth_token.dart`)
- Repositories: Abstract `{entity}_repository.dart`, Implementation `{entity}_repository_impl.dart`
- Components: `{component}_name.dart` in snake_case (e.g., `book_card.dart`, `signin_form.dart`)
- DI/Injection: `{feature}_injection.dart` or `authentication_injection.dart`
- Routers: `{feature}_router.dart` (e.g., `auth_router.dart`, `books_router.dart`)

**Directories:**
- Snake case for all directories
- Features organized under `lib/features/{feature_name}/`
- Clean Architecture layers: `domain/`, `data/`, `presentation/`
- Component hierarchy: `atoms/`, `molecules/`, `organisms/`, `templates/`
- Injection files: `*_injection.dart` at feature root

## Where to Add New Code

**New Feature:**
1. Create `lib/features/{feature_name}/` directory
2. Add layers: `domain/`, `data/`, `presentation/`
3. Create `{feature_name}_injection.dart` at root
4. Create `{feature_name}_router.dart` at root
5. Primary code:
   - Domain entities: `lib/features/{feature}/domain/entities/`
   - Domain repository abstract: `lib/features/{feature}/domain/repositories/`
   - Data models: `lib/features/{feature}/data/models/`
   - Repository implementation: `lib/features/{feature}/data/repositories/`
   - ViewModel: `lib/features/{feature}/presentation/view_models/`
   - Screen: `lib/features/{feature}/presentation/views/`
6. Update `lib/core/di/injection.dart` to call feature injection
7. Update `lib/router.dart` to include feature routes

**New Component/Module (within feature):**
- Component library folder: `lib/features/{feature}/presentation/components/atoms/`, `.../molecules/`, `.../organisms/`
- Example: Adding BookRating atom → `lib/features/books/presentation/components/atoms/book_rating.dart`

**Utilities:**
- Shared helpers: `lib/shared/utils/`
- Feature-specific helpers: `lib/features/{feature}/presentation/utils/` (if needed)
- Core utils: `lib/core/utils/`

**Validators:**
- Shared validators: `lib/shared/validators/{field}_validator.dart`

**Interceptors/Network:**
- New interceptor: `lib/core/network/interceptors/{function}_interceptor.dart`

## Special Directories

**`lib/l10n/`:**
- Purpose: Localization files and generated localizations
- Generated: Yes (app_localizations.dart generated from .arb files)
- Committed: .arb source files committed, generated file may be in .gitignore

**`test/`:**
- Purpose: Unit and widget tests
- Structure mirrors `lib/` directory
- Named: `{component}_test.dart`
- Contains test helpers and fixtures

**`assets/`:**
- Purpose: Images, fonts, and static resources
- Committed: Yes
- Subdirectories: `images/`, `fonts/`, `icons/`

**`android/`, `ios/`:**
- Purpose: Platform-specific code
- Committed: Native wrappers and configuration
- Generated: Some files auto-generated

---

*Structure analysis: 2025-01-17*
