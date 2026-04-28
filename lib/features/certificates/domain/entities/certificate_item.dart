import 'package:json_annotation/json_annotation.dart';

part 'certificate_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CertificateItem {
  final String name;
  final String fingerprint; // SHA256 of DER
  final String pem;
  final String subject;
  final String issuer;
  final bool isIgnored;
  final DateTime addedAt;

  CertificateItem({
    required this.name,
    required this.fingerprint,
    required this.pem,
    required this.subject,
    required this.issuer,
    required this.isIgnored,
    required this.addedAt,
  });

  factory CertificateItem.fromJson(Map<String, dynamic> json) =>
      _$CertificateItemFromJson(json);

  Map<String, dynamic> toJson() => _$CertificateItemToJson(this);

  CertificateItem copyWith({
    String? name,
    String? fingerprint,
    String? pem,
    String? subject,
    String? issuer,
    bool? isIgnored,
    DateTime? addedAt,
  }) {
    return CertificateItem(
      name: name ?? this.name,
      fingerprint: fingerprint ?? this.fingerprint,
      pem: pem ?? this.pem,
      subject: subject ?? this.subject,
      issuer: issuer ?? this.issuer,
      isIgnored: isIgnored ?? this.isIgnored,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
