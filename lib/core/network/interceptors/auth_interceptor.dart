import 'package:dio/dio.dart';
import '../dio_client.dart';
import '../api_constants.dart';
import '../token_provider.dart';
import '../../logging/logger.dart';

class AuthInterceptor extends QueuedInterceptor {
  final DioClient dioClient;
  final TokenProvider tokenProvider;
  static const String _logTag = 'AuthInterceptor';

  final List<String> _excludedPaths = [
    ApiConstants.signIn,
    ApiConstants.signUp,
    ApiConstants.authRefresh,
    ApiConstants.s3Prefix,
  ];

  AuthInterceptor({required this.dioClient, required this.tokenProvider});

  bool _shouldIntercept(RequestOptions options) {
    // 1. Check if the request is targeting the API origin
    if (options.baseUrl.isEmpty) return false;

    final baseUri = Uri.parse(options.baseUrl);
    final requestUri = options.uri;

    // Use a basic origin check (scheme, host, port) to identify API requests.
    // This prevents leaking tokens to third-party domains.
    final bool isApiOrigin =
        requestUri.scheme == baseUri.scheme &&
        requestUri.host == baseUri.host &&
        requestUri.port == baseUri.port;

    if (!isApiOrigin) return false;

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
        _shouldIntercept(err.requestOptions)) {
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
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $currentToken';
          final response = await dioClient.dio.fetch<dynamic>(options);
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
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newToken';
          final response = await dioClient.dio.fetch<dynamic>(options);
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
