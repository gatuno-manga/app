import 'package:dio/dio.dart';

import '../../device/device_id_service.dart';
import '../../logging/logger.dart';
import '../api_origin.dart';
import '../dio_client.dart';

/// Attaches the per-device `x-device-id` header to API-origin requests.
///
/// Only requests whose resolved URI matches [RequestOptions.baseUrl] (scheme,
/// host, port) receive the header, preventing leakage to third-party or S3 URLs.
/// Unlike [AuthInterceptor], all API endpoints (including sign-in, sign-up,
/// refresh, and MFA verification) receive `x-device-id`.
class DeviceIdInterceptor extends Interceptor {
  static const String _logTag = 'DeviceIdInterceptor';
  static const String headerName = 'x-device-id';

  final DeviceIdService _deviceIdService;

  DeviceIdInterceptor({required DeviceIdService deviceIdService})
    : _deviceIdService = deviceIdService;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (isApiOrigin(options)) {
      try {
        final deviceId = await _deviceIdService.getDeviceId();
        options.headers[headerName] = deviceId;
      } catch (e, stackTrace) {
        AppLogger.e('Failed to resolve device ID', e, stackTrace, _logTag);
      }
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
