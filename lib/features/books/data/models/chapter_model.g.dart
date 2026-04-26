// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChapterModel _$ChapterModelFromJson(Map<String, dynamic> json) => ChapterModel(
  id: ChapterModel._parseString(json['id']),
  title: json['title'] as String?,
  index: ChapterModel._parseIndex(json['index']),
  scrapingStatus: ChapterModel._parseScrapingStatus(json['scrapingStatus']),
  read: json['read'] as bool? ?? false,
);

Map<String, dynamic> _$ChapterModelToJson(ChapterModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'read': instance.read,
      'id': instance.id,
      'index': instance.index,
      'scrapingStatus': _$ScrapingStatusEnumMap[instance.scrapingStatus],
    };

const _$ScrapingStatusEnumMap = {
  ScrapingStatus.process: 'process',
  ScrapingStatus.ready: 'ready',
  ScrapingStatus.error: 'error',
};

ChapterListModel _$ChapterListModelFromJson(Map<String, dynamic> json) =>
    ChapterListModel(
      data: (json['data'] as List<dynamic>)
          .map((e) => ChapterModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: ChapterListModel._parseStringNullable(json['nextCursor']),
      hasNextPage: json['hasNextPage'] as bool,
    );

Map<String, dynamic> _$ChapterListModelToJson(ChapterListModel instance) =>
    <String, dynamic>{
      'hasNextPage': instance.hasNextPage,
      'data': instance.data,
      'nextCursor': instance.nextCursor,
    };
