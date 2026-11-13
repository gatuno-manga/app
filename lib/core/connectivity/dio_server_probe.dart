import 'package:dio/dio.dart';

import '../network/api_constants.dart';
import '../network/dio_client.dart';
import 'server_connectivity_service.dart';

/// Probes the configured server's liveness endpoint, the same endpoint the
/// URL validation on the welcome screen uses.
ServerProbe dioServerProbe(
  DioClient dioClient, {
  Duration timeout = const Duration(seconds: 3),
}) {
  return () async {
    if (dioClient.dio.options.baseUrl.isEmpty) return null;
    try {
      final response = await dioClient.dio.get<dynamic>(
        ApiConstants.healthLiveness,
        options: Options(sendTimeout: timeout, receiveTimeout: timeout),
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      // Any answer means the server is reachable, even an error status.
      return e.response != null;
    }
  };
}
