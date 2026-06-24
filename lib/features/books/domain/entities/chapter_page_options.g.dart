// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_page_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChapterPageOptions _$ChapterPageOptionsFromJson(Map<String, dynamic> json) =>
    ChapterPageOptions(
      cursor: json['cursor'] as String?,
      limit: json['limit'] == null
          ? const PositiveInt(200)
          : PositiveInt.fromJson((json['limit'] as num).toInt()),
      order:
          $enumDecodeNullable(_$ChapterSortOrderEnumMap, json['order']) ??
          ChapterSortOrder.asc,
    );

Map<String, dynamic> _$ChapterPageOptionsToJson(ChapterPageOptions instance) =>
    <String, dynamic>{
      'cursor': ?instance.cursor,
      'limit': instance.limit,
      'order': ChapterPageOptions._orderToJson(instance.order),
    };

const _$ChapterSortOrderEnumMap = {
  ChapterSortOrder.asc: 'asc',
  ChapterSortOrder.desc: 'desc',
};
