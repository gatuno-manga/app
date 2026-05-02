// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_metadata_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageMetadataModel _$ImageMetadataModelFromJson(Map<String, dynamic> json) =>
    ImageMetadataModel(
      width: const DoubleConverter().fromJson(json['width']),
      height: const DoubleConverter().fromJson(json['height']),
      sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
      mimeType: json['mimeType'] as String?,
      blurHash: json['blurHash'] as String?,
      dominantColor: json['dominantColor'] as String?,
      pHash: json['pHash'] as String?,
      entropy: const DoubleConverter().fromJson(json['entropy']),
      formatOrigin: json['formatOrigin'] as String?,
    );

Map<String, dynamic> _$ImageMetadataModelToJson(ImageMetadataModel instance) =>
    <String, dynamic>{
      'width': const DoubleConverter().toJson(instance.width),
      'height': const DoubleConverter().toJson(instance.height),
      'sizeBytes': instance.sizeBytes,
      'mimeType': instance.mimeType,
      'blurHash': instance.blurHash,
      'dominantColor': instance.dominantColor,
      'pHash': instance.pHash,
      'entropy': _$JsonConverterToJson<dynamic, double>(
        instance.entropy,
        const DoubleConverter().toJson,
      ),
      'formatOrigin': instance.formatOrigin,
    };

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
