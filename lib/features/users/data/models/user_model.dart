import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  @JsonKey(name: 'sub')
  final String id;
  final String email;
  @JsonKey(name: 'username')
  final String? userName;
  final String? name;
  final List<String> roles;
  @JsonKey(defaultValue: 0)
  final int maxWeightSensitiveContent;

  UserModel({
    required this.id,
    required this.email,
    this.userName,
    this.name,
    required this.roles,
    required this.maxWeightSensitiveContent,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromJwt(Map<String, dynamic> payload) {
    final sub = payload['sub'] as String? ?? '';
    final email = payload['email'] as String? ?? '';
    final roles = payload['roles'] as Iterable<dynamic>?;

    if (sub.isEmpty || email.isEmpty || roles == null) {
      throw const FormatException(
        'Invalid JWT payload: missing required fields or empty values (sub, email, or roles)',
      );
    }

    return UserModel.fromJson(payload);
  }

  String get displayName => name ?? userName ?? email.split('@')[0];
}
