import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart'
    show extraFromNetworkKey;

import '../../connectivity/connectivity_service.dart';
import '../dio_client.dart';
import '../exceptions.dart';

/// Feeds request outcomes into [ConnectivityService], so a failed request
/// flips the app offline at once and an answer from the server flips it back.
///
/// Only requests to the configured server count (an image on another host or
/// a candidate URL being validated says nothing about it), and only answers
/// that came over the network: the HTTP cache interceptor resolves fresh hits
/// with `callFollowingResponseInterceptor`, so they do reach this one.
class ConnectivityInterceptor extends Interceptor {
  final ConnectivityService _connectivity;
  final String Function() _baseUrl;

  /// Gateway errors come from a reverse proxy whose backend is down.
  static const Set<int> _gatewayErrors = {502, 503, 504};

  ConnectivityInterceptor(
    this._connectivity, {
    required String Function() baseUrl,
  }) : _baseUrl = baseUrl;

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (_isServer(response.requestOptions) &&
        response.extra[extraFromNetworkKey] != false) {
      _connectivity.reportReachable();
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_isServer(err.requestOptions)) {
      final status = err.response?.statusCode;
      if (err.isUnreachable) {
        _connectivity.reportUnreachable();
      } else if (_gatewayErrors.contains(status)) {
        // The proxy answered, not the server: let the probe decide.
        _connectivity.checkNow();
      } else if (status != null) {
        _connectivity.reportReachable();
      }
    }
    handler.next(err);
  }

  bool _isServer(RequestOptions options) {
    final base = Uri.tryParse(_baseUrl());
    if (base == null || base.host.isEmpty) return false;
    final uri = options.uri;
    return uri.scheme == base.scheme &&
        uri.host == base.host &&
        uri.port == base.port;
  }
}

void setupConnectivityInterceptor(
  DioClient dioClient,
  ConnectivityService connectivity,
) {
  dioClient.dio.interceptors.insert(
    0,
    ConnectivityInterceptor(
      connectivity,
      baseUrl: () => dioClient.dio.options.baseUrl,
    ),
  );
}
