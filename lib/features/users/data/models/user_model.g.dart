// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['sub'] as String,
  email: json['email'] as String,
  userName: json['username'] as String?,
  name: json['name'] as String?,
  roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
  maxWeightSensitiveContent:
      (json['maxWeightSensitiveContent'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'sub': instance.id,
  'email': instance.email,
  'username': instance.userName,
  'name': instance.name,
  'roles': instance.roles,
  'maxWeightSensitiveContent': instance.maxWeightSensitiveContent,
};
