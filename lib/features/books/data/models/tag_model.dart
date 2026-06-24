import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/tag.dart';
import '../../domain/value_objects/tag_id.dart';
import '../../domain/value_objects/tag_name.dart';

part 'tag_model.g.dart';

@JsonSerializable()
class TagModel extends Tag {
  const TagModel({required super.id, required super.name});

  factory TagModel.fromJson(Map<String, dynamic> json) =>
      _$TagModelFromJson(json);

  Map<String, dynamic> toJson() => _$TagModelToJson(this);
}
