import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../../../core/base/base_stream_view_model.dart';
import '../../domain/entities/certificate_item.dart';
import '../../domain/use_cases/certificates_service.dart';
import '../../exceptions/certificates_exceptions.dart';
import 'package:equatable/equatable.dart';

class CertificatesState extends Equatable {
  final bool isLoading;
  final CertificateException? error;
  final List<CertificateItem> trustedCertificates;
  final List<CertificateItem> ignoredCertificates;

  const CertificatesState({
    required this.isLoading,
    this.error,
    required this.trustedCertificates,
    required this.ignoredCertificates,
  });

  factory CertificatesState.initial() {
    return const CertificatesState(
      isLoading: false,
      error: null,
      trustedCertificates: [],
      ignoredCertificates: [],
    );
  }

  CertificatesState copyWith({
    bool? isLoading,
    CertificateException? Function()? error,
    List<CertificateItem>? trustedCertificates,
    List<CertificateItem>? ignoredCertificates,
  }) {
    return CertificatesState(
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      trustedCertificates: trustedCertificates ?? this.trustedCertificates,
      ignoredCertificates: ignoredCertificates ?? this.ignoredCertificates,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        trustedCertificates,
        ignoredCertificates,
      ];
}

class CertificatesViewModel extends BaseStreamViewModel<CertificatesState> {
  final CertificatesService _certificatesService;

  CertificatesViewModel(this._certificatesService)
      : super(CertificatesState.initial()) {
    _certificatesService.addListener(_syncState);
    _syncState();
  }

  void _syncState() {
    emit(state.copyWith(
      trustedCertificates: _certificatesService.trustedCertificates,
      ignoredCertificates: _certificatesService.ignoredCertificates,
    ));
  }

  @override
  void dispose() {
    _certificatesService.removeListener(_syncState);
    super.dispose();
  }

  void clearError() {
    emit(state.copyWith(error: () => null));
  }

  Future<bool> addCertificateFromFile(String name) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pem', 'crt', 'cer'],
    );

    if (result == null || result.files.isEmpty) return false;

    final file = result.files.single;
    String fileContent;

    emit(state.copyWith(isLoading: true, error: () => null));

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
      emit(state.copyWith(isLoading: false));
      return true;
    } on CertificateException catch (e) {
      emit(state.copyWith(isLoading: false, error: () => e));
      return false;
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: () => CertificateDecodingException()));
      return false;
    }
  }

  Future<bool> addManualCertificate(String name, String pem) async {
    emit(state.copyWith(isLoading: true, error: () => null));

    try {
      await _certificatesService.addManualCertificate(name, pem);
      emit(state.copyWith(isLoading: false));
      return true;
    } on CertificateException catch (e) {
      emit(state.copyWith(isLoading: false, error: () => e));
      return false;
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: () => CertificateDecodingException()));
      return false;
    }
  }

  Future<void> deleteCertificate(String fingerprint) async {
    await _certificatesService.deleteCertificate(fingerprint);
  }
}
