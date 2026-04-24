import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

class DioClient {
  late final Dio dio;
  List<String> _allowedBadCertificateUrls = [];

  DioClient({String baseUrl = '', HttpClient? httpClient}) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        contentType: 'application/json',
        headers: const {'x-client-platform': 'mobile'},
      ),
    );

    if (baseUrl.isNotEmpty) {
      _setupCertificatePinning(baseUrl, httpClient);
    }
  }

  void updateBaseUrl(String baseUrl, {HttpClient? httpClient}) {
    dio.options.baseUrl = baseUrl;
    _setupCertificatePinning(baseUrl, httpClient);
  }

  void updateAllowedBadCertificateUrls(List<String> urls, {HttpClient? httpClient}) {
    _allowedBadCertificateUrls = urls;
    _setupCertificatePinning(dio.options.baseUrl, httpClient);
  }

  void _setupCertificatePinning(String baseUrl, HttpClient? httpClient) {
    if (baseUrl.isEmpty) return;

    // Support self-signed certificates for the configured API host
    final baseUri = Uri.tryParse(baseUrl);
    if (baseUri == null) return;

    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = httpClient ?? HttpClient();
        client.badCertificateCallback = (cert, host, port) {
          if (host == baseUri.host) return true;
          return _allowedBadCertificateUrls.any((url) {
            final uri = Uri.tryParse(url);
            return uri != null && uri.host == host;
          });
        };
        return client;
      },
    );
  }
}
