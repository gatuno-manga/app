import 'package:dio/dio.dart';

import '../../device/device_id_service.dart';
import '../dio_client.dart';

/// Attaches the per-device `x-device-id` header to API-origin requests.
///
/// Only requests whose resolved URI matches [RequestOptions.baseUrl] (scheme,
/// host, port) receive the header, preventing leakage to third-party or S3 URLs.
/// Unlike [AuthInterceptor], all API endpoints (including sign-in, sign-up,
/// refresh, and MFA verification) receive `x-device-id`.
class DeviceIdInterceptor extends Interceptor {
  static const String headerName = 'x-device-id';

  final DeviceIdService _deviceIdService;

  DeviceIdInterceptor({required DeviceIdService deviceIdService})
    : _deviceIdService = deviceIdService;

  bool _isApiOrigin(RequestOptions options) {
    if (options.baseUrl.isEmpty) return false;
    final baseUri = Uri.tryParse(options.baseUrl);
    if (baseUri == null) return false;

    final requestUri = options.uri;
    return requestUri.scheme == baseUri.scheme &&
        requestUri.host == baseUri.host &&
        requestUri.port == baseUri.port;
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isApiOrigin(options)) {
      final deviceId = await _deviceIdService.getDeviceId();
      options.headers[headerName] = deviceId;
    }
    return handler.next(options);
  }
}

void setupDeviceIdInterceptor(
  DioClient dioClient,
  DeviceIdService deviceIdService,
) {
  dioClient.dio.interceptors.add(
    DeviceIdInterceptor(deviceIdService: deviceIdService),
  );
}
