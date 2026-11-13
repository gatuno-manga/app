import 'package:dio/dio.dart';

import '../../connectivity/connectivity_service.dart';
import '../dio_client.dart';
import '../exceptions.dart';

/// Feeds every request outcome into [ConnectivityService], so a failed request
/// flips the app offline at once and any answer from the server flips it back.
///
/// Added before the HTTP cache interceptor: a response served from that cache
/// never reaches this interceptor, so it cannot fake reachability.
class ConnectivityInterceptor extends Interceptor {
  final ConnectivityService _connectivity;

  ConnectivityInterceptor(this._connectivity);

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _connectivity.reportReachable();
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.isUnreachable) {
      _connectivity.reportUnreachable();
    } else if (err.response != null) {
      // The server answered, even if with an error status.
      _connectivity.reportReachable();
    }
    handler.next(err);
  }
}

void setupConnectivityInterceptor(
  DioClient dioClient,
  ConnectivityService connectivity,
) {
  dioClient.dio.interceptors.insert(0, ConnectivityInterceptor(connectivity));
}
