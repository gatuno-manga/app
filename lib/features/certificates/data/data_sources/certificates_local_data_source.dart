import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/certificate_item.dart';

class CertificatesStorage {
  static const String _certificatesKey = 'certificates';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> setCertificates(List<CertificateItem> certificates) async {
    final jsonList = certificates.map((cert) => cert.toJson()).toList();
    await _storage.write(key: _certificatesKey, value: jsonEncode(jsonList));
  }

  Future<List<CertificateItem>> getCertificates() async {
    final value = await _storage.read(key: _certificatesKey);
    if (value == null || value.isEmpty) return [];
    try {
      final decoded = jsonDecode(value);
      if (decoded is List) {
        return decoded
            .map(
              (item) => CertificateItem.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
