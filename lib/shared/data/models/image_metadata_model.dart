import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/image_metadata.dart';

part 'image_metadata_model.g.dart';

class DoubleConverter implements JsonConverter<double, dynamic> {
  const DoubleConverter();
  @override
  double fromJson(dynamic json) =>
      double.tryParse(json?.toString() ?? '0') ?? 0.0;
  @override
  dynamic toJson(double object) => object;
}

@JsonSerializable(converters: [DoubleConverter()])
class ImageMetadataModel extends ImageMetadata {
  const ImageMetadataModel({
    required super.width,
    required super.height,
    super.sizeBytes,
    super.mimeType,
    super.blurHash,
    super.dominantColor,
    super.pHash,
    super.entropy,
    super.formatOrigin,
  });

  factory ImageMetadataModel.fromJson(Map<String, dynamic> json) =>
      _$ImageMetadataModelFromJson(json);

  Map<String, dynamic> toJson() => _$ImageMetadataModelToJson(this);
}
