// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_book_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateBookRequestDto _$CreateBookRequestDtoFromJson(
  Map<String, dynamic> json,
) => CreateBookRequestDto(
  title: RequestTitle.fromJson(json['title'] as String),
  url: RequestUrl.fromJson(json['url'] as String),
  reason: json['reason'] == null
      ? null
      : RequestReason.fromJson(json['reason'] as String?),
);

Map<String, dynamic> _$CreateBookRequestDtoToJson(
  CreateBookRequestDto instance,
) => <String, dynamic>{
  'title': instance.title.toJson(),
  'url': instance.url.toJson(),
  'reason': instance.reason?.toJson(),
};
