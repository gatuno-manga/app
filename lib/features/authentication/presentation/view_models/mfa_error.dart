import '../../../../core/network/exceptions.dart';

enum MfaError {
  invalidCode,
  tooManyAttempts,
  challengeExpired,
  network,
  unknown,
}

MfaError mfaErrorFrom(Object error) {
  if (error is MfaChallengeExpiredException) return MfaError.challengeExpired;
  if (error is TooManyRequestsException) return MfaError.tooManyAttempts;
  if (error is NetworkException) return MfaError.network;
  if (error is UnauthorizedException || error is ValidationException) {
    return MfaError.invalidCode;
  }
  return MfaError.unknown;
}
