import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_image.g.dart';

@JsonSerializable()
class UserImage extends Equatable {
  final String path;
  final Map<String, dynamic>? metadata;

  const UserImage({required this.path, this.metadata});

  static const guest = UserImage(path: '');

  bool get isGuest => path.isEmpty;

  @override
  List<Object?> get props => [path, metadata];

  factory UserImage.fromJson(Map<String, dynamic> json) =>
      _$UserImageFromJson(json);

  Map<String, dynamic> toJson() => _$UserImageToJson(this);
}
