import 'package:dio/dio.dart';

/// Returns `true` when [options.uri] shares the same scheme, host, and port
/// as [baseUrl] (defaulting to [RequestOptions.baseUrl]).
bool isApiOrigin(RequestOptions options, {String? baseUrl}) {
  final effectiveBaseUrl = baseUrl ?? options.baseUrl;
  if (effectiveBaseUrl.isEmpty) return false;
  final baseUri = Uri.tryParse(effectiveBaseUrl);
  if (baseUri == null || baseUri.scheme.isEmpty || baseUri.host.isEmpty) {
    return false;
  }
  final requestUri = options.uri;
  return requestUri.scheme == baseUri.scheme &&
      requestUri.host == baseUri.host &&
      requestUri.port == baseUri.port;
}
