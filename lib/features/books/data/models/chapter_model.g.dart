// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChapterModel _$ChapterModelFromJson(Map<String, dynamic> json) => ChapterModel(
  id: ChapterId.fromJson(const StringConverter().fromJson(json['id'])),
  title: json['title'] == null
      ? null
      : ChapterTitle.fromJson(const StringConverter().fromJson(json['title'])),
  index: const IndexConverter().fromJson(json['index']),
  scrapingStatus: const ScrapingStatusConverter().fromJson(
    json['scrapingStatus'],
  ),
  read: json['read'] as bool? ?? false,
  completed: json['completed'] as bool? ?? false,
  lastPage: json['lastPage'] == null
      ? const PositiveInt(0)
      : PositiveInt.fromJson((json['lastPage'] as num).toInt()),
);

Map<String, dynamic> _$ChapterModelToJson(ChapterModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'index': const IndexConverter().toJson(instance.index),
      'scrapingStatus': const ScrapingStatusConverter().toJson(
        instance.scrapingStatus,
      ),
      'read': instance.read,
      'completed': instance.completed,
      'lastPage': instance.lastPage,
    };

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
