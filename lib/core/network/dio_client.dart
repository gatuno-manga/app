import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../config/app_config.dart';
import '../../features/certificates/domain/use_cases/certificates_service.dart';

class DioClient {
  late final Dio dio;
  final CertificatesService _certificatesService;

  DioClient({
    required CertificatesService certificatesService,
    String baseUrl = '',
    HttpClient? httpClient,
  }) : _certificatesService = certificatesService {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        contentType: 'application/json',
        headers: const {
          'x-client-platform': 'mobile',
          'Referer': AppConfig.referer,
        },
      ),
    );

    _setupHttpClientAdapter(httpClient);
  }

  void updateBaseUrl(String baseUrl, {HttpClient? httpClient}) {
    dio.options.baseUrl = baseUrl;
    _setupHttpClientAdapter(httpClient);
  }

  void _setupHttpClientAdapter(HttpClient? httpClient) {
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = httpClient ?? HttpClient();
        client.badCertificateCallback = (cert, host, port) {
          final status = _certificatesService.checkStatus(cert, host);

          if (status == CertificateStatus.trusted) {
            return true;
          }

          if (status == CertificateStatus.unknown) {
            _certificatesService.addPending(host, cert);
          }

          return false;
        };
        return client;
      },
    );
  }
}
