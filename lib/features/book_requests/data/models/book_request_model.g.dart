// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookRequestModel _$BookRequestModelFromJson(Map<String, dynamic> json) =>
    BookRequestModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      reason: json['reason'] as String?,
      status: json['status'] as String,
      adminId: json['adminId'] as String?,
      rejectionMessage: json['rejectionMessage'] as String?,
      createdAt: Timestamp.fromJson(json['createdAt']),
      updatedAt: Timestamp.fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$BookRequestModelToJson(BookRequestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'url': instance.url,
      'reason': instance.reason,
      'status': instance.status,
      'adminId': instance.adminId,
      'rejectionMessage': instance.rejectionMessage,
      'createdAt': instance.createdAt.toJson(),
      'updatedAt': instance.updatedAt.toJson(),
    };
