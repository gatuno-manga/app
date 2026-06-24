// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookRequestModel _$BookRequestModelFromJson(Map<String, dynamic> json) =>
    BookRequestModel(
      id: RequestId.fromJson(json['id'] as String),
      userId: UserId.fromJson(json['userId'] as String),
      title: RequestTitle.fromJson(json['title'] as String),
      url: RequestUrl.fromJson(json['url'] as String),
      reason: RequestReason.fromJson(json['reason'] as String?),
      status: $enumDecode(_$RequestStatusEnumMap, json['status']),
      adminId: json['adminId'] == null
          ? null
          : UserId.fromJson(json['adminId'] as String),
      rejectionMessage: RequestRejectionMessage.fromJson(
        json['rejectionMessage'] as String?,
      ),
      createdAt: Timestamp.fromJson(json['createdAt']),
      updatedAt: Timestamp.fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$BookRequestModelToJson(BookRequestModel instance) =>
    <String, dynamic>{
      'id': instance.id.toJson(),
      'userId': instance.userId.toJson(),
      'title': instance.title.toJson(),
      'url': instance.url.toJson(),
      'reason': instance.reason.toJson(),
      'status': instance.status.toJson(),
      'adminId': instance.adminId?.toJson(),
      'rejectionMessage': instance.rejectionMessage.toJson(),
      'createdAt': instance.createdAt.toJson(),
      'updatedAt': instance.updatedAt.toJson(),
    };

const _$RequestStatusEnumMap = {
  RequestStatus.pending: 'pending',
  RequestStatus.approved: 'approved',
  RequestStatus.rejected: 'rejected',
};
