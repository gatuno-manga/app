// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_book_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateBookRequestDto _$CreateBookRequestDtoFromJson(
  Map<String, dynamic> json,
) => CreateBookRequestDto(
  title: json['title'] as String,
  url: json['url'] as String,
  reason: json['reason'] as String?,
);

Map<String, dynamic> _$CreateBookRequestDtoToJson(
  CreateBookRequestDto instance,
) => <String, dynamic>{
  'title': instance.title,
  'url': instance.url,
  'reason': instance.reason,
};
