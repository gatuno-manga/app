import 'dart:io';

class CustomCertHttpOverrides extends HttpOverrides {
  final SecurityContext securityContext;

  CustomCertHttpOverrides(this.securityContext);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(securityContext);

    client.badCertificateCallback = (cert, host, port) {
      return false;
    };

    return client;
  }
}
