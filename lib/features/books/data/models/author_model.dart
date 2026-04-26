import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/author.dart';

part 'author_model.g.dart';

@JsonSerializable()
class AuthorModel extends Author {
  const AuthorModel({required super.id, required super.name});

  factory AuthorModel.fromJson(Map<String, dynamic> json) =>
      _$AuthorModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorModelToJson(this);
}
