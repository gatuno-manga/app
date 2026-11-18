import 'package:dio/dio.dart';
import '../api_origin.dart';
import '../dio_client.dart';
import '../api_constants.dart';
import '../token_provider.dart';
import '../../logging/logger.dart';

/// Attaches the access token and retries once after a 401.
///
/// A plain [Interceptor], not a `QueuedInterceptor`: the token refresh and
/// the 401 retry go through this same Dio, so a queue would make them wait
/// behind the request that is waiting for them (#159). `TokenProvider`
/// already makes concurrent callers share one refresh, which the API needs:
/// it rotates refresh tokens and revokes the session on reuse.
class AuthInterceptor extends Interceptor {
  final DioClient dioClient;
  final TokenProvider tokenProvider;
  static const String _logTag = 'AuthInterceptor';

  final List<String> _excludedPaths = [
    ApiConstants.signIn,
    ApiConstants.signUp,
    ApiConstants.authRefresh,
    ApiConstants.mfaVerifyLogin,
    ApiConstants.s3Prefix,
  ];

  /// Endpoints where a 401 means "wrong code", not "expired session": replaying
  /// them after a token refresh would double the attempts on a guessable code.
  final List<String> _noRetryPaths = [
    ApiConstants.mfaTotpVerifySetup,
    ApiConstants.mfaTotpDisable,
  ];

  /// Marks a request this interceptor already retried after a 401, so a
  /// second 401 goes to the caller instead of starting another refresh.
  static const String retriedExtraKey = 'authRetried';

  AuthInterceptor({required this.dioClient, required this.tokenProvider});

  Future<Response<dynamic>> _retry(RequestOptions options, String token) {
    options.headers['Authorization'] = 'Bearer $token';
    options.extra[retriedExtraKey] = true;
    return dioClient.dio.fetch<dynamic>(options);
  }

  bool _shouldIntercept(RequestOptions options) {
    // 1. Check if the request is targeting the API origin
    if (!isApiOrigin(options)) return false;

    final requestUri = options.uri;

    // 2. Check if the path is excluded from getting the token
    final bool isExcluded = _excludedPaths.any(
      (path) =>
          options.path == path ||
          requestUri.path.endsWith(path) ||
          requestUri.path.startsWith(path),
    );

    return !isExcluded;
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_shouldIntercept(options)) {
      // getValidToken handles both expired and near-expiry logic
      final token = await tokenProvider.getValidToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        AppLogger.d('Token attached to request: ${options.path}', _logTag);
      } else {
        AppLogger.d('No token available for request: ${options.path}', _logTag);
      }
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        _shouldIntercept(err.requestOptions) &&
        err.requestOptions.extra[retriedExtraKey] != true &&
        !_noRetryPaths.any(err.requestOptions.uri.path.endsWith)) {
      AppLogger.i('Intercepted 401 for: ${err.requestOptions.path}', _logTag);

      // Check if the token was already refreshed by another concurrent request
      final currentToken = await tokenProvider.getValidToken();
      final authHeader = err.requestOptions.headers['Authorization']
          ?.toString();
      final requestToken = authHeader?.replaceFirst('Bearer ', '');

      if (currentToken != null && currentToken != requestToken) {
        AppLogger.i(
          'Concurrent refresh detected, retrying original request',
          _logTag,
        );
        try {
          final response = await _retry(err.requestOptions, currentToken);
          return handler.resolve(response);
        } catch (e) {
          AppLogger.e(
            'Retry after concurrent refresh failed',
            e,
            null,
            _logTag,
          );
          return handler.next(err);
        }
      }

      // If we are still using the current token and got a 401, force a refresh
      try {
        AppLogger.i('Triggering forced token refresh after 401', _logTag);
        final newToken = await tokenProvider.getValidToken(forceRefresh: true);

        if (newToken != null && newToken.isNotEmpty) {
          AppLogger.i('Retrying original request with new token', _logTag);
          final response = await _retry(err.requestOptions, newToken);
          return handler.resolve(response);
        } else {
          AppLogger.e(
            'Token refresh returned null, failing',
            null,
            null,
            _logTag,
          );
          return handler.next(err);
        }
      } catch (e) {
        AppLogger.e('Token refresh or retry failed', e, null, _logTag);
        final forwardError = e is DioException
            ? e
            : DioException(
                requestOptions: err.requestOptions,
                error: e,
                type: DioExceptionType.unknown,
                message: 'Token refresh failed: $e',
              );
        return handler.next(forwardError);
      }
    }
    return handler.next(err);
  }
}

void setupAuthInterceptor(DioClient dioClient, TokenProvider tokenProvider) {
  dioClient.dio.interceptors.add(
    AuthInterceptor(dioClient: dioClient, tokenProvider: tokenProvider),
  );
}
