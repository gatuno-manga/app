// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChapterModel _$ChapterModelFromJson(Map<String, dynamic> json) => ChapterModel(
  id: const StringConverter().fromJson(json['id']),
  title: const StringConverter().fromJson(json['title']),
  index: const IndexConverter().fromJson(json['index']),
  scrapingStatus: const ScrapingStatusConverter().fromJson(
    json['scrapingStatus'],
  ),
  read: json['read'] as bool? ?? false,
  completed: json['completed'] as bool? ?? false,
);

Map<String, dynamic> _$ChapterModelToJson(ChapterModel instance) =>
    <String, dynamic>{
      'id': const StringConverter().toJson(instance.id),
      'title': _$JsonConverterToJson<dynamic, String>(
        instance.title,
        const StringConverter().toJson,
      ),
      'index': const IndexConverter().toJson(instance.index),
      'scrapingStatus': const ScrapingStatusConverter().toJson(
        instance.scrapingStatus,
      ),
      'read': instance.read,
      'completed': instance.completed,
    };

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

ChapterListModel _$ChapterListModelFromJson(Map<String, dynamic> json) =>
    ChapterListModel(
      data: const ChapterListConverter().fromJson(json['data'] as List?),
      nextCursor: const StringNullableConverter().fromJson(json['nextCursor']),
      hasNextPage: json['hasNextPage'] as bool,
    );

Map<String, dynamic> _$ChapterListModelToJson(ChapterListModel instance) =>
    <String, dynamic>{
      'data': const ChapterListConverter().toJson(instance.data),
      'nextCursor': const StringNullableConverter().toJson(instance.nextCursor),
      'hasNextPage': instance.hasNextPage,
    };
