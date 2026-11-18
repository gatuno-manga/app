import '../../../core/exceptions/exceptions.dart';

class UnauthorizedException extends AppExceptions {
  final String? code;

  UnauthorizedException({String? message, this.code})
    : super(message ?? 'Invalid credentials', statusCode: 401);
}

class AuthException extends AppExceptions {
  AuthException(super.message);
}

/// Thrown when `POST /auth/refresh` hits the backend's per-user refresh lock
/// (`409 REFRESH_IN_PROGRESS`). Transient; wait [retryAfter] and retry once.
class RefreshInProgressException extends AppExceptions {
  final Duration retryAfter;

  RefreshInProgressException({String? message, Duration? retryAfter})
    : retryAfter = retryAfter ?? const Duration(seconds: 1),
      super(message ?? 'Refresh already in progress', statusCode: 409);
}

/// Thrown when the backend rejects a refresh or logout request with
/// `403 CSRF_TOKEN_INVALID`. The session itself is still alive.
class CsrfTokenInvalidException extends AppExceptions {
  CsrfTokenInvalidException({String? message})
    : super(message ?? 'CSRF token invalid', statusCode: 403);
}

/// Thrown by sign-in when the backend demands an MFA step-up. Carries the
/// short-lived challenge token to be exchanged at `verify-login`.
class MfaRequiredException extends AppExceptions {
  final String mfaToken;
  MfaRequiredException(this.mfaToken)
    : super('MFA verification required', statusCode: 200);
}

/// The MFA challenge token was rejected (expired or malformed): the user has
/// to sign in again.
class MfaChallengeExpiredException extends AppExceptions {
  MfaChallengeExpiredException()
    : super('MFA challenge expired', statusCode: 401);
}
