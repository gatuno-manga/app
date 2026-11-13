import 'package:dio/dio.dart';

import '../network/api_constants.dart';
import '../network/dio_client.dart';
import '../network/interceptors/cache_interceptor.dart';
import 'server_connectivity_service.dart';

/// Probes the configured server's liveness endpoint, the same endpoint the
/// URL validation on the welcome screen uses. Only a 2xx means online. The
/// probe bypasses the HTTP cache: a cached answer proves nothing.
ServerProbe dioServerProbe(
  DioClient dioClient, {
  Duration timeout = const Duration(seconds: 3),
}) {
  return () async {
    if (dioClient.dio.options.baseUrl.isEmpty) return null;
    try {
      final response = await dioClient.dio.get<dynamic>(
        ApiConstants.healthLiveness,
        options: noHttpCacheOptions().copyWith(
          sendTimeout: timeout,
          receiveTimeout: timeout,
        ),
      );
      final status = response.statusCode ?? 0;
      return status >= 200 && status < 300;
    } on DioException {
      // An error status counts as down too: a reverse proxy answers 502/503
      // while the backend behind it is gone.
      return false;
    }
  };
}
