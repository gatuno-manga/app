# External Integrations

**Analysis Date:** 2025-01-10

## APIs & External Services

**REST API:**
- Backend API Service - Core business logic and data persistence
  - SDK/Client: Dio 5.9.2
  - Base URL: Configurable via `SettingsService` and `DioClient`
  - Default endpoint (development): `http://localhost:3000/api`
  - Documentation: `lib/core/network/api_constants.dart`

## Data Storage

**Backend Communication:**
- HTTP-based REST API (no direct database integration from mobile)
  - Client: `DioClient` in `lib/core/network/dio_client.dart`
  - Connection management: Dio HTTP client with custom timeout settings
    - Connect timeout: 5 seconds
    - Receive timeout: 3 seconds

**Local Storage - Credentials:**
- Secure credential storage using platform-native implementation
  - Provider: FlutterSecureStorage
  - Location in code: `lib/core/network/cookies/secure_cookie_storage.dart`
  - Stores: JWT authentication tokens, session cookies
  - Implementation: Implements Dart `Storage` interface for `PersistCookieJar`

**Local Storage - Cache:**
- File-based HTTP response caching
  - Provider: `http_cache_file_store` 2.0.1
  - Location in code: `lib/core/network/interceptors/cache_interceptor.dart`
  - Strategy: Caches GET requests and successful responses
  - Retrieval: Via application cache directory (`path_provider`)

**Local Storage - Settings:**
- In-memory settings with persistent backing
  - Implementation: `SettingsStorage` in `lib/features/settings/data/data_sources/settings_local_data_source.dart`
  - Stores: API base URL configuration, user preferences
  - Initialization: Loaded during app startup in `main.dart` (line 14)

**Cookies:**
- Persistent cookie storage using secure encryption
  - Client: `cookie_jar` 4.0.8 with `PersistCookieJar`
  - Interceptor: `dio_cookie_manager` 3.1.2
  - Storage backend: `SecureCookieStorage` (FlutterSecureStorage-backed)
  - Implementation: `lib/core/network/interceptors/cookie_interceptor.dart`

## API Endpoints

**Authentication:**
- `POST /auth/signin` - User sign-in
  - Location: `lib/core/network/api_constants.dart` (line 3)
  - Excluded from token requirement (can be called without Bearer token)
- `POST /auth/signup` - User registration
  - Location: `lib/core/network/api_constants.dart` (line 4)
  - Excluded from token requirement
- `POST /auth/refresh` - Token refresh
  - Location: `lib/core/network/api_constants.dart` (line 5)
  - Used for JWT token rotation
- `POST /auth/logout` - Logout
  - Location: `lib/core/network/api_constants.dart` (line 6)

**Books (Resource):**
- `GET /books` - Fetch books collection
  - Location: `lib/core/network/api_constants.dart` (line 9)
  - Requires: Bearer token authentication

## Authentication & Identity

**Auth Provider:**
- Custom JWT-based authentication
  - Implementation: `AuthService` in `lib/features/authentication/domain/use_cases/auth_service.dart`
  - Token storage: FlutterSecureStorage via `SecureCookieStorage`
  - Token validation: JWT decoder in `lib/core/utils/jwt_decoder.dart`

**Token Management:**
- JWT tokens with automatic refresh
  - Interceptor: `AuthInterceptor` (`lib/core/network/interceptors/auth_interceptor.dart`)
  - Header format: `Authorization: Bearer <token>`
  - Eager refresh: Triggered if token expires within 2 minutes
  - Origin check: Prevents token leakage to third-party domains
  - 401 handling: Atomic token refresh with request retry

**Session Management:**
- Cookie-based session persistence
  - Cookies managed by `PersistCookieJar` with secure storage
  - Automatic cookie injection via `dio_cookie_manager` interceptor
  - Cookies survive app restarts (persisted to secure storage)

## Monitoring & Observability

**Error Tracking:**
- In-app error logging (no external error service)
  - Logger: `AppLogger` in `lib/core/logging/logger.dart`
  - Router error handler: Captures navigation errors in `createAppRouter()` (lib/router.dart line 26-28)

**Logs:**
- Console logging with tag-based organization
  - Log levels: Debug, Info, Warning, Error
  - Tags: Used for filtering (e.g., 'AuthInterceptor', 'ROUTER')
  - Interceptor logging: `LoggingInterceptor` (`lib/core/network/interceptors/logging_interceptor.dart`)
  - Request/response details logged for debugging

## Validation & Input Handling

**Email Validation:**
- email_validator 3.0.0 - Email format validation
  - Used in authentication forms (`signin_form.dart`, `signup_form.dart`)
  - Provides consistent email validation across sign-in and sign-up flows

## Network Configuration

**Certificate Management:**
- Self-signed certificate support for development environments
  - Implementation: `_setupCertificatePinning()` in `lib/core/network/dio_client.dart` (lines 29-45)
  - Feature: Allows trusting self-signed certificates from specific hosts
  - Use case: Local network API servers during development
  - Validation: Host matching via `Uri.host` comparison

**Request Headers:**
- Custom platform identification header
  - Header: `x-client-platform: mobile`
  - Added in `DioClient` BaseOptions (line 15, dio_client.dart)
  - Purpose: Server-side API version management and feature flagging

**Request Caching Strategy:**
- HTTP cache using `dio_cache_interceptor`
  - Configuration: Respects HTTP cache headers (Cache-Control)
  - Storage: File-based in application cache directory
  - Location: `lib/core/network/interceptors/cache_interceptor.dart`

## Internationalization

**Localization Provider:**
- Custom app localization with Flutter's standard system
  - Supported locales: English (en), Portuguese (pt)
  - Implementation file: `lib/l10n/app_localizations.dart` (auto-generated)
  - Configuration: `l10n.yaml`
  - Usage: `AppLocalizations` delegate in `main.dart` (line 44)

## Environment Configuration

**Required environment variables:**
- `API_BASE_URL` - REST API base URL (required for app initialization)
  - Example: `http://localhost:3000`
  - Read during app startup by `SettingsService`

**Configuration file:**
- `.env.example` - Example environment configuration (see root of project)
- `.env` - Actual configuration (not committed, created locally from .env.example)

**Runtime Configuration:**
- Base URL can be changed at runtime via settings screen
  - Implementation: `SettingsService.updateApiUrl()` 
  - Updated in: `DioClient.updateBaseUrl()` (lib/core/network/dio_client.dart, line 24)

## Webhooks & Callbacks

**Incoming:**
- No incoming webhooks configured
- App is pull-based (client initiates all requests to backend)

**Outgoing:**
- No outgoing webhooks to third-party services
- Authentication flows: Built-in refresh token mechanism (refresh endpoint)

## Security Considerations

**Transport Security:**
- HTTPS support with self-signed certificate handling
- Certificate pinning available (host-level validation)
- Platform defaults: TLS 1.2+ (enforced by iOS/Android platforms)

**Credential Security:**
- JWT tokens stored in platform-native secure storage
  - Android: KeyStore
  - iOS: Keychain
- Cookies encrypted before storage

**API Origin Validation:**
- AuthInterceptor validates request origin before attaching tokens
  - Prevents token leakage via redirect or man-in-the-middle
  - Checks: scheme, host, port matching between base URL and request URL

---

*Integration audit: 2025-01-10*
