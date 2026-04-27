import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../../../core/base/safe_change_notifier.dart';
import '../../domain/entities/certificate_item.dart';
import '../../domain/use_cases/certificates_service.dart';

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

  List<CertificateItem> get trustedCertificates =>
      _certificatesService.trustedCertificates;

  List<CertificateItem> get ignoredCertificates =>
      _certificatesService.ignoredCertificates;

  Future<void> addCertificateFromFile(String host) async {
    final result = await FilePicker.pickFiles(
      type: FileType.any,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    String fileContent;
    
    if (file.bytes != null) {
      fileContent = String.fromCharCodes(file.bytes!);
    } else if (file.path != null) {
      fileContent = await File(file.path!).readAsString();
    } else {
      return;
    }
    
    await _certificatesService.addManualCertificate(host, fileContent);
  }
  
  Future<void> addManualCertificate(String host, String pem) async {
    await _certificatesService.addManualCertificate(host, pem);
  }

  Future<void> deleteCertificate(String fingerprint) async {
    await _certificatesService.deleteCertificate(fingerprint);
  }
}
