// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'certificate_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CertificateItem _$CertificateItemFromJson(Map<String, dynamic> json) =>
    CertificateItem(
      host: json['host'] as String,
      fingerprint: json['fingerprint'] as String,
      pem: json['pem'] as String,
      subject: json['subject'] as String,
      issuer: json['issuer'] as String,
      isIgnored: json['is_ignored'] as bool,
      addedAt: DateTime.parse(json['added_at'] as String),
    );

Map<String, dynamic> _$CertificateItemToJson(CertificateItem instance) =>
    <String, dynamic>{
      'host': instance.host,
      'fingerprint': instance.fingerprint,
      'pem': instance.pem,
      'subject': instance.subject,
      'issuer': instance.issuer,
      'is_ignored': instance.isIgnored,
      'added_at': instance.addedAt.toIso8601String(),
    };
