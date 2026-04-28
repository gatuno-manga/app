import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../entities/certificate_item.dart';
import '../../data/data_sources/certificates_local_data_source.dart';
import '../../../../core/network/http_overrides.dart';
import '../../../../core/logging/logger.dart';

enum CertificateStatus { trusted, ignored, unknown }

class CertificatesService extends ChangeNotifier {
  static const String _logTag = 'CertificatesService';
  final CertificatesStorage _storage;
  List<CertificateItem> _certificates = [];
  final Map<String, X509Certificate> _pendingCerts = {};

  CertificatesService(this._storage);

  Future<void> init() async {
    _certificates = await _storage.getCertificates();
    _applyOverrides();
    notifyListeners();
  }

  List<CertificateItem> get trustedCertificates =>
      _certificates.where((c) => !c.isIgnored).toList();

  List<CertificateItem> get ignoredCertificates =>
      _certificates.where((c) => c.isIgnored).toList();

  CertificateStatus checkStatus(X509Certificate cert, String host) {
    final fingerprint = _calculateFingerprint(cert.der);

    final index = _certificates.indexWhere((c) => c.fingerprint == fingerprint);
    if (index == -1) {
      AppLogger.d('Certificate status unknown for host: $host', _logTag);
      return CertificateStatus.unknown;
    }

    final item = _certificates[index];
    final status = item.isIgnored
        ? CertificateStatus.ignored
        : CertificateStatus.trusted;
    AppLogger.d('Certificate status for host $host: $status', _logTag);
    return status;
  }

  String _calculateFingerprint(Uint8List der) {
    return sha256.convert(der).toString();
  }

  String _calculateFingerprintFromPem(String pem) {
    try {
      final lines = pem.split('\n');
      final base64String = lines
          .where(
            (line) =>
                !line.startsWith('-----BEGIN') && !line.startsWith('-----END'),
          )
          .join('')
          .trim();
      final der = base64.decode(base64String);
      return _calculateFingerprint(der);
    } catch (e, stackTrace) {
      AppLogger.e(
        'Error calculating fingerprint from PEM',
        e,
        stackTrace,
        _logTag,
      );
      return '';
    }
  }

  void addPending(String host, X509Certificate cert) {
    _pendingCerts[host] = cert;
  }

  X509Certificate? getPending(String host) => _pendingCerts[host];

  void removePending(String host) {
    _pendingCerts.remove(host);
  }

  Future<void> trustCertificate(String name, X509Certificate cert) async {
    AppLogger.i('Trusting certificate for host: $name', _logTag);
    final newItem = CertificateItem(
      name: name,
      fingerprint: _calculateFingerprint(cert.der),
      pem: cert.pem,
      subject: cert.subject,
      issuer: cert.issuer,
      isIgnored: false,
      addedAt: DateTime.now(),
    );
    await _addOrUpdate(newItem);
    removePending(name);
  }

  Future<void> ignoreCertificate(String host, X509Certificate cert) async {
    AppLogger.i('Ignoring certificate for host: $host', _logTag);
    final newItem = CertificateItem(
      name: host,
      fingerprint: _calculateFingerprint(cert.der),
      pem: cert.pem,
      subject: cert.subject,
      issuer: cert.issuer,
      isIgnored: true,
      addedAt: DateTime.now(),
    );
    await _addOrUpdate(newItem);
    removePending(host);
  }

  Future<void> addManualCertificate(String name, String pem) async {
    AppLogger.i('Adding manual certificate for host: $name', _logTag);
    final fingerprint = _calculateFingerprintFromPem(pem);
    final newItem = CertificateItem(
      name: name,
      fingerprint: fingerprint,
      pem: pem,
      subject: 'Manual: $name',
      issuer: 'Manual: $name',
      isIgnored: false,
      addedAt: DateTime.now(),
    );
    await _addOrUpdate(newItem);
  }

  Future<void> deleteCertificate(String fingerprint) async {
    AppLogger.i('Deleting certificate with fingerprint: $fingerprint', _logTag);
    _certificates.removeWhere((c) => c.fingerprint == fingerprint);
    await _storage.setCertificates(_certificates);
    _applyOverrides();
    notifyListeners();
  }

  Future<void> _addOrUpdate(CertificateItem item) async {
    _certificates.removeWhere(
      (c) =>
          (item.fingerprint.isNotEmpty && c.fingerprint == item.fingerprint) ||
          (item.fingerprint.isEmpty && c.name == item.name),
    );
    _certificates.add(item);
    await _storage.setCertificates(_certificates);
    _applyOverrides();
    notifyListeners();
  }

  void _applyOverrides() {
    AppLogger.d(
      'Applying HttpOverrides with ${trustedCertificates.length} trusted certificates',
      _logTag,
    );
    final context = SecurityContext(withTrustedRoots: true);
    for (final cert in trustedCertificates) {
      if (cert.pem.isNotEmpty) {
        try {
          context.setTrustedCertificatesBytes(utf8.encode(cert.pem));
        } catch (e, stackTrace) {
          AppLogger.e(
            'Error loading certificate for ${cert.name}',
            e,
            stackTrace,
            _logTag,
          );
        }
      }
    }
    HttpOverrides.global = CustomCertHttpOverrides(context);
  }
}
