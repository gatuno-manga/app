# Technology Stack

**Analysis Date:** 2025-01-10

## Languages

**Primary:**
- Dart 3.11.1+ - Cross-platform mobile application development
- Used throughout `lib/` directory for all application logic

**Secondary:**
- Kotlin/Swift - Platform-specific code in `android/` and `ios/` directories
- YAML - Configuration files (`pubspec.yaml`, `analysis_options.yaml`, `l10n.yaml`)

## Runtime

**Environment:**
- Flutter SDK (linked to Dart 3.11.1)
- Dart VM for development and testing

**Package Manager:**
- Pub (Dart package manager)
- Lockfile: `pubspec.lock` (present)

## Frameworks

**Core:**
- Flutter 3.x - Cross-platform mobile UI framework
- Material Design 3 - UI component library

**State Management:**
- Provider 6.1.2 - Consumer-based state management
  - Used for `AuthService` and `SettingsService` in `main.dart`
  - Implemented as `ChangeNotifierProvider` for reactive updates
- GetIt 9.2.1 - Service locator for dependency injection
  - Configured in `lib/core/di/injection.dart`

**Routing & Navigation:**
- go_router 17.1.0 - Declarative routing and navigation
  - Entry point: `lib/router.dart`
  - Supports nested routing via `StatefulShellRoute` in multi-tab application

**HTTP & Networking:**
- Dio 5.9.2 - HTTP client with advanced features
  - Configuration: `lib/core/network/dio_client.dart`
  - Supports certificate pinning for self-signed certificates
  - Timeout: 5s connect, 3s receive

**Caching & Cookies:**
- dio_cache_interceptor 4.0.0 - HTTP request caching layer
  - Implementation: `lib/core/network/interceptors/cache_interceptor.dart`
- cookie_jar 4.0.8 - Cookie storage and management
- dio_cookie_manager 3.1.2 - Cookie interceptor for Dio
  - Implementation: `lib/core/network/interceptors/cookie_interceptor.dart`

**Security & Storage:**
- flutter_secure_storage 10.0.0 - Platform-native secure credential storage
  - Wrapper class: `lib/core/network/cookies/secure_cookie_storage.dart`
  - Used for JWT tokens and sensitive data

**Internationalization (i18n):**
- flutter_localizations (SDK) - Flutter localization support
- intl 0.20.2 - Internationalization library
- Custom app localizations with `AppLocalizations` delegate
- Supported locales: English (en), Portuguese (pt)

**Utilities:**
- path_provider 2.1.5 - Access to application directories (cache, documents, etc.)
  - Used for cache file storage in interceptor
- http_cache_file_store 2.0.1 - File-based HTTP cache storage
- email_validator 3.0.0 - Email validation utility
- optional 6.1.0+1 - Optional type handling
- cupertino_icons 1.0.8 - iOS-style icon set

**Testing:**
- flutter_test (SDK) - Flutter testing framework
- mocktail 1.0.4 - Mocking library for unit tests
- Test files co-located with feature modules (e.g., `test/core/`, `test/features/`)

**Code Generation & Linting:**
- flutter_launcher_icons 0.14.4 - App icon generation
  - Configuration in `pubspec.yaml` (lines 39-48)
  - Android minimum SDK: 21
  - Generates adaptive icons with background and foreground

**Analysis & Linting:**
- flutter_lints 6.0.0 - Flutter lint rules
  - Configuration: `analysis_options.yaml`
  - Strict mode enabled: strict-casts, strict-inference, strict-raw-types
  - Custom rules: prefer single quotes, always declare return types, require trailing commas

## Key Dependencies

**Critical:**
- Dio 5.9.2 - Central to all HTTP communication
  - All API requests routed through `DioClient` singleton
  - Supports interceptors for auth, caching, logging, cookies
- Provider 6.1.2 - Synchronizes app state across UI
  - Used for reactive authentication and settings state

**Infrastructure:**
- flutter_secure_storage 10.0.0 - Stores authentication tokens securely
- go_router 17.1.0 - Enables complex nested navigation with deep linking
- GetIt 9.2.1 - Manages dependency resolution and lifecycle

## Configuration

**Environment:**
- Variables configured via `.env` file (see `.env.example`)
- Critical variable: `API_BASE_URL` - REST API endpoint
- Default development URL: `http://localhost:3000`
- Base URL is configurable at runtime via `SettingsService`

**Build:**
- `pubspec.yaml` - Main dependency and Flutter configuration
- `analysis_options.yaml` - Linter rules and analysis settings
- `l10n.yaml` - Internationalization configuration (lines 1-10)
- Supported locales configured in `main.dart` (line 49)

**Code Generation:**
- `flutter: generate: true` - Enables automatic code generation
- Excludes generated files from analysis: `*.g.dart`, `*.freezed.dart`
- Generated localizations in `lib/l10n/app_localizations.dart`

## Platform Requirements

**Development:**
- Dart SDK 3.11.1+
- Flutter SDK (compatible with Dart 3.11.1)
- Android SDK (minimum API 21, configured in launcher icons)
- Xcode (for iOS development)
- Java OpenJDK 17.0.2 (for Android build tools)

**Production:**
- Target: Android (minimum API 21) and iOS
- Self-signed certificate support enabled for local network API servers
- HTTP client adapter: `IOHttpClientAdapter` for certificate management

---

*Stack analysis: 2025-01-10*
