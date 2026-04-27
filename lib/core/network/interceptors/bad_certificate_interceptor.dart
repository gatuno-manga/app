import 'package:dio/dio.dart';
import '../../../features/certificates/domain/use_cases/certificates_service.dart';
import '../dio_client.dart';
import '../../router/router_keys.dart';
import '../../logging/logger.dart';
import '../../../shared/components/organisms/certificate_trust_dialog.dart';

class BadCertificateInterceptor extends Interceptor {
  static const String _logTag = 'BadCertificateInterceptor';
  final CertificatesService _certificatesService;
  final Dio _dio;
  bool _isShowingDialog = false;

  BadCertificateInterceptor(this._certificatesService, this._dio);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.type != DioExceptionType.badCertificate) {
      return handler.next(err);
    }

    final host = err.requestOptions.uri.host;
    final cert = _certificatesService.getPending(host);

    if (cert == null) {
      AppLogger.w(
          'Bad certificate detected for $host but no pending certificate found',
          _logTag);
      return handler.next(err);
    }

    if (_isShowingDialog) {
      return handler.next(err);
    }

    _isShowingDialog = true;
    final context = rootNavigatorKey.currentContext;
    bool? result;
    
    if (context != null) {
      result = await CertificateTrustDialog.show(context, host);
    } else {
      AppLogger.w(
          'Could not show trust dialog: rootNavigatorKey.currentContext is null',
          _logTag);
    }
    
    _isShowingDialog = false;

    if (result == true) {
      AppLogger.i(
          'User trusted certificate for $host. Retrying request...', _logTag);
      await _certificatesService.trustCertificate(host, cert);

      try {
        final response = await _dio.fetch<dynamic>(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    if (result == false) {
      AppLogger.i('User ignored certificate for $host', _logTag);
      await _certificatesService.ignoreCertificate(host, cert);
    }

    return handler.next(err);
  }
}

void setupBadCertificateInterceptor(
    DioClient dioClient, CertificatesService certificatesService) {
  dioClient.dio.interceptors
      .add(BadCertificateInterceptor(certificatesService, dioClient.dio));
}
