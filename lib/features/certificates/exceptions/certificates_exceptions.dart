import '../../../core/exceptions/exceptions.dart';

abstract class CertificateException extends AppExceptions {
  CertificateException(super.message);
}

class CertificateInvalidFormatException extends CertificateException {
  final String? content;
  CertificateInvalidFormatException({
    String message = 'Invalid certificate format',
    this.content,
  }) : super(message);
}

class CertificateFileMissingException extends CertificateException {
  CertificateFileMissingException([
    super.message = 'Certificate file is missing or unreadable',
  ]);
}

class CertificateDecodingException extends CertificateException {
  CertificateDecodingException([
    super.message = 'Failed to decode certificate file',
  ]);
}

class CertificateEmptyFingerprintException extends CertificateException {
  CertificateEmptyFingerprintException([
    super.message = 'Failed to calculate certificate fingerprint',
  ]);
}
