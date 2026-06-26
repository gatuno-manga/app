import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../../../core/base/safe_change_notifier.dart';
import '../../domain/entities/certificate_item.dart';
import '../../domain/use_cases/certificates_service.dart';

import '../../exceptions/certificates_exceptions.dart';

class CertificatesViewModel extends SafeChangeNotifier {
  final CertificatesService _certificatesService;

  CertificatesViewModel(this._certificatesService) {
    _certificatesService.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _certificatesService.removeListener(notifyListeners);
    super.dispose();
  }

  CertificateException? _error;
  CertificateException? get error => _error;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  List<CertificateItem> get trustedCertificates =>
      _certificatesService.trustedCertificates;

  List<CertificateItem> get ignoredCertificates =>
      _certificatesService.ignoredCertificates;

  Future<bool> addCertificateFromFile(String name) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pem', 'crt', 'cer'],
    );

    if (result == null || result.files.isEmpty) return false;

    final file = result.files.single;
    String fileContent;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (file.path != null) {
        fileContent = await File(file.path!).readAsString();
      } else if (file.size > 0) {
        final bytes = await file.xFile.readAsBytes();
        fileContent = String.fromCharCodes(bytes);
      } else {
        throw CertificateFileMissingException();
      }

      await _certificatesService.addManualCertificate(name, fileContent);
      _isLoading = false;
      notifyListeners();
      return true;
    } on CertificateException catch (e) {
      _error = e;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = CertificateDecodingException();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addManualCertificate(String name, String pem) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _certificatesService.addManualCertificate(name, pem);
      _isLoading = false;
      notifyListeners();
      return true;
    } on CertificateException catch (e) {
      _error = e;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = CertificateDecodingException();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteCertificate(String fingerprint) async {
    await _certificatesService.deleteCertificate(fingerprint);
  }
}
