import 'dart:io';
import 'package:dio/dio.dart';
import '../../features/authentication/exceptions/exceptions.dart';
import '../exceptions/exceptions.dart';

export '../../features/authentication/exceptions/exceptions.dart';
export '../exceptions/exceptions.dart';

extension DioExceptionCertificateExtension on DioException {
  bool get isBadCertificate {
    if (type == DioExceptionType.badCertificate) return true;
    if (type == DioExceptionType.unknown && error is HandshakeException) {
      return error.toString().contains('CERTIFICATE_VERIFY_FAILED');
    }
    return false;
  }

  /// Whether the server could not be reached at all, as opposed to answering
  /// with an error status or failing the certificate check.
  bool get isUnreachable {
    switch (type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return true;
      case DioExceptionType.unknown:
        return error is SocketException;
      case DioExceptionType.badCertificate:
      case DioExceptionType.badResponse:
      case DioExceptionType.cancel:
        return false;
    }
  }
}

class NetworkException extends AppExceptions {
  NetworkException({String? message})
    : super(message ?? 'No internet connection or server unreachable');
}

class ValidationException extends AppExceptions {
  final Map<String, dynamic>? errors;
  ValidationException({String? message, this.errors})
    : super(message ?? 'Validation failed', statusCode: 400);
}

class TooManyRequestsException extends AppExceptions {
  TooManyRequestsException({String? message})
    : super(message ?? 'Too many requests', statusCode: 429);
}

/// The server cannot be reached and the requested data is not cached.
///
/// View models show the shared offline empty state for it.
class OfflineException extends AppExceptions {
  OfflineException({String? message})
    : super(message ?? 'Offline and the requested data is not saved');
}

class ServerException extends AppExceptions {
  ServerException({String? message, int? statusCode})
    : super(message ?? 'Internal server error', statusCode: statusCode ?? 500);
}

class ApiExceptionHandler {
  static AppExceptions handle(DioException error) {
    final dynamic responseData = error.response?.data;
    String? message;

    if (responseData is Map) {
      message = responseData['message']?.toString();
    }

    final statusCode = error.response?.statusCode;

    switch (statusCode) {
      case 400:
        return ValidationException(
          message: message,
          errors: responseData is Map
              ? responseData['errors'] as Map<String, dynamic>?
              : null,
        );
      case 401:
        return UnauthorizedException(message: message);
      case 403:
        return AuthException('Access denied: ${message ?? ''}');
      case 404:
        return AuthException('Resource not found');
      case 429:
        return TooManyRequestsException(message: message);
      case 500:
        return ServerException(message: message, statusCode: 500);
      default:
        if (error.isUnreachable) {
          return NetworkException();
        }
        return AuthException(
          message ?? error.message ?? 'An unexpected error occurred',
        );
    }
  }
}
