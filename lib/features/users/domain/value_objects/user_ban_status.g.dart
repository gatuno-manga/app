// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_ban_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserBanStatus _$UserBanStatusFromJson(Map<String, dynamic> json) =>
    UserBanStatus(
      isBanned: json['isBanned'] as bool? ?? false,
      suspendedUntil: UserDateTime.fromJson(json['suspendedUntil'] as String?),
      suspensionReason: json['suspensionReason'] as String?,
    );

Map<String, dynamic> _$UserBanStatusToJson(UserBanStatus instance) =>
    <String, dynamic>{
      'isBanned': instance.isBanned,
      'suspendedUntil': instance.suspendedUntil.toJson(),
      'suspensionReason': instance.suspensionReason,
    };
