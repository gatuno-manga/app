// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_chapter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadingPageModel _$ReadingPageModelFromJson(
  Map<String, dynamic> json,
) => ReadingPageModel(
  id: const StringConverter().fromJson(json['id']),
  url: const StringConverter().fromJson(ReadingPageModel._readUrl(json, 'url')),
  index: const IntConverter().fromJson(json['index']),
  imageMetadata: json['metadata'] == null
      ? null
      : ImageMetadataModel.fromJson(json['metadata'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ReadingPageModelToJson(ReadingPageModel instance) =>
    <String, dynamic>{
      'id': const StringConverter().toJson(instance.id),
      'url': const StringConverter().toJson(instance.url),
      'index': const IntConverter().toJson(instance.index),
      'metadata': instance.imageMetadata,
    };

ChapterCommentModel _$ChapterCommentModelFromJson(Map<String, dynamic> json) =>
    ChapterCommentModel(
      id: const StringConverter().fromJson(json['id']),
      content: const StringConverter().fromJson(json['content']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      userId: const StringConverter().fromJson(json['userId']),
      userName: const StringConverter().fromJson(json['userName']),
    );

Map<String, dynamic> _$ChapterCommentModelToJson(
  ChapterCommentModel instance,
) => <String, dynamic>{
  'id': const StringConverter().toJson(instance.id),
  'content': const StringConverter().toJson(instance.content),
  'createdAt': instance.createdAt.toIso8601String(),
  'userId': const StringConverter().toJson(instance.userId),
  'userName': const StringConverter().toJson(instance.userName),
};

ReadingChapterModel _$ReadingChapterModelFromJson(Map<String, dynamic> json) =>
    ReadingChapterModel(
      id: const StringConverter().fromJson(json['id']),
      title: const StringConverter().fromJson(json['title']),
      originalUrl: const StringConverter().fromJson(json['originalUrl']),
      index: const DoubleConverter().fromJson(json['index']),
      contentType: const ContentTypeConverter().fromJson(json['contentType']),
      content: const StringConverter().fromJson(json['content']),
      contentFormat: const ContentFormatConverter().fromJson(
        json['contentFormat'],
      ),
      documentPath: const StringConverter().fromJson(json['documentPath']),
      documentFormat: const DocumentFormatConverter().fromJson(
        json['documentFormat'],
      ),
      scrapingStatus: const ScrapingStatusConverter().fromJson(
        json['scrapingStatus'],
      ),
      retries: const IntConverter().fromJson(json['retries']),
      isFinal: json['isFinal'] as bool? ?? false,
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      previous: const StringConverter().fromJson(json['previous']),
      next: const StringConverter().fromJson(json['next']),
      bookId: const StringConverter().fromJson(json['bookId']),
      bookTitle: const StringConverter().fromJson(json['bookTitle']),
      totalChapters: const IntConverter().fromJson(json['totalChapters']),
      pages: const ReadingPageListConverter().fromJson(json['pages'] as List?),
      comments: const ChapterCommentListConverter().fromJson(
        json['comments'] as List?,
      ),
    );

Map<String, dynamic> _$ReadingChapterModelToJson(
  ReadingChapterModel instance,
) => <String, dynamic>{
  'id': const StringConverter().toJson(instance.id),
  'title': _$JsonConverterToJson<dynamic, String>(
    instance.title,
    const StringConverter().toJson,
  ),
  'originalUrl': const StringConverter().toJson(instance.originalUrl),
  'index': const DoubleConverter().toJson(instance.index),
  'contentType': const ContentTypeConverter().toJson(instance.contentType),
  'content': _$JsonConverterToJson<dynamic, String>(
    instance.content,
    const StringConverter().toJson,
  ),
  'contentFormat': const ContentFormatConverter().toJson(
    instance.contentFormat,
  ),
  'documentPath': _$JsonConverterToJson<dynamic, String>(
    instance.documentPath,
    const StringConverter().toJson,
  ),
  'documentFormat': const DocumentFormatConverter().toJson(
    instance.documentFormat,
  ),
  'scrapingStatus': const ScrapingStatusConverter().toJson(
    instance.scrapingStatus,
  ),
  'retries': const IntConverter().toJson(instance.retries),
  'isFinal': instance.isFinal,
  'deletedAt': instance.deletedAt?.toIso8601String(),
  'previous': _$JsonConverterToJson<dynamic, String>(
    instance.previous,
    const StringConverter().toJson,
  ),
  'next': _$JsonConverterToJson<dynamic, String>(
    instance.next,
    const StringConverter().toJson,
  ),
  'bookId': const StringConverter().toJson(instance.bookId),
  'bookTitle': const StringConverter().toJson(instance.bookTitle),
  'totalChapters': const IntConverter().toJson(instance.totalChapters),
  'pages': const ReadingPageListConverter().toJson(instance.pages),
  'comments': const ChapterCommentListConverter().toJson(instance.comments),
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
