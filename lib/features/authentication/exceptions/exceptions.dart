import '../../../core/exceptions/exceptions.dart';

class UnauthorizedException extends AppExceptions {
  UnauthorizedException({String? message})
    : super(message ?? 'Invalid credentials', statusCode: 401);
}

class AuthException extends AppExceptions {
  AuthException(super.message);
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
