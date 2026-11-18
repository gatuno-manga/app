import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/network/exceptions.dart';

void main() {
  group('ApiExceptionHandler', () {
    test('handles 400 ValidationException', () {
      final error = DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          statusCode: 400,
          requestOptions: RequestOptions(path: ''),
          data: {
            'message': 'Invalid input',
            'errors': {'email': 'invalid'},
          },
        ),
      );

      final result = ApiExceptionHandler.handle(error);

      expect(result, isA<ValidationException>());
      expect(result.message, 'Invalid input');
      expect((result as ValidationException).errors?['email'], 'invalid');
    });

    test('handles 401 UnauthorizedException and preserves code', () {
      final error = DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(path: ''),
          data: {'message': 'Unauthorized', 'code': 'REFRESH_TOKEN_INVALID'},
        ),
      );

      final result = ApiExceptionHandler.handle(error);

      expect(result, isA<UnauthorizedException>());
      expect(result.message, 'Unauthorized');
      expect((result as UnauthorizedException).code, 'REFRESH_TOKEN_INVALID');
    });

    test('handles 403 Forbidden', () {
      final error = DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          statusCode: 403,
          requestOptions: RequestOptions(path: ''),
          data: {'message': 'Forbidden'},
        ),
      );

      final result = ApiExceptionHandler.handle(error);

      expect(result, isA<AuthException>());
      expect(result.message, contains('Access denied'));
    });

    test('handles 403 CSRF_TOKEN_INVALID as CsrfTokenInvalidException', () {
      final error = DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          statusCode: 403,
          requestOptions: RequestOptions(path: ''),
          data: {'message': 'Invalid CSRF token', 'code': 'CSRF_TOKEN_INVALID'},
        ),
      );

      final result = ApiExceptionHandler.handle(error);

      expect(result, isA<CsrfTokenInvalidException>());
      expect(result.statusCode, 403);
      expect(result.message, 'Invalid CSRF token');
    });

    test(
      'handles 409 REFRESH_IN_PROGRESS with Retry-After parsing and clamping',
      () {
        RefreshInProgressException parseWithHeader(String? retryAfter) {
          final error = DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              statusCode: 409,
              requestOptions: RequestOptions(path: ''),
              headers: retryAfter == null
                  ? Headers()
                  : Headers.fromMap({
                      'Retry-After': [retryAfter],
                    }),
              data: {
                'message': 'Refresh already in progress',
                'code': 'REFRESH_IN_PROGRESS',
              },
            ),
          );
          final result = ApiExceptionHandler.handle(error);
          expect(result, isA<RefreshInProgressException>());
          return result as RefreshInProgressException;
        }

        expect(parseWithHeader('2').retryAfter, const Duration(seconds: 2));
        expect(parseWithHeader(null).retryAfter, const Duration(seconds: 1));
        expect(parseWithHeader('0').retryAfter, Duration.zero);
        expect(parseWithHeader('30').retryAfter, const Duration(seconds: 5));
        expect(parseWithHeader('abc').retryAfter, const Duration(seconds: 1));
        expect(parseWithHeader('-2').retryAfter, const Duration(seconds: 1));
      },
    );

    test('handles 409 without REFRESH_IN_PROGRESS as AuthException', () {
      final error = DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          statusCode: 409,
          requestOptions: RequestOptions(path: ''),
          data: {'message': 'Conflict', 'code': 'OTHER_CONFLICT'},
        ),
      );

      final result = ApiExceptionHandler.handle(error);

      expect(result, isA<AuthException>());
      expect(result.message, 'Conflict');
    });

    test('handles 404 Not Found', () {
      final error = DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          statusCode: 404,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = ApiExceptionHandler.handle(error);

      expect(result, isA<AuthException>());
      expect(result.message, contains('Resource not found'));
    });

    test('handles 500 ServerException', () {
      final error = DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          statusCode: 500,
          requestOptions: RequestOptions(path: ''),
          data: {'message': 'Internal error'},
        ),
      );

      final result = ApiExceptionHandler.handle(error);

      expect(result, isA<ServerException>());
      expect(result.message, 'Internal error');
    });

    test('handles network timeouts', () {
      final error = DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      );

      final result = ApiExceptionHandler.handle(error);

      expect(result, isA<NetworkException>());
    });

    test('handles unknown errors', () {
      final error = DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.unknown,
        message: 'Unknown error',
      );

      final result = ApiExceptionHandler.handle(error);

      expect(result, isA<AuthException>());
      expect(result.message, 'Unknown error');
    });
  });
}
