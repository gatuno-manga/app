// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_chapter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadingPageModel _$ReadingPageModelFromJson(
  Map<String, dynamic> json,
) => ReadingPageModel(
  id: ReadingPageId.fromJson(const StringConverter().fromJson(json['id'])),
  url: ReadingPageUrl.fromJson(
    const StringConverter().fromJson(ReadingPageModel._readUrl(json, 'url')),
  ),
  index: PositiveInt.fromJson(const IntConverter().fromJson(json['index'])),
  imageMetadata: json['metadata'] == null
      ? null
      : ImageMetadataModel.fromJson(json['metadata'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ReadingPageModelToJson(ReadingPageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'index': instance.index,
      'metadata': instance.imageMetadata,
    };

ChapterCommentModel _$ChapterCommentModelFromJson(Map<String, dynamic> json) =>
    ChapterCommentModel(
      id: CommentId.fromJson(const StringConverter().fromJson(json['id'])),
      content: CommentContent.fromJson(
        const StringConverter().fromJson(json['content']),
      ),
      createdAt: Timestamp.fromJson(json['createdAt']),
      userId: UserId.fromJson(const StringConverter().fromJson(json['userId'])),
      userName: UserDisplayName.fromJson(
        const StringConverter().fromJson(json['userName']),
      ),
    );

Map<String, dynamic> _$ChapterCommentModelToJson(
  ChapterCommentModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'content': instance.content,
  'createdAt': instance.createdAt,
  'userId': instance.userId,
  'userName': instance.userName,
};

ReadingChapterModel _$ReadingChapterModelFromJson(
  Map<String, dynamic> json,
) => ReadingChapterModel(
  id: ChapterId.fromJson(const StringConverter().fromJson(json['id'])),
  title: json['title'] == null
      ? null
      : ChapterTitle.fromJson(const StringConverter().fromJson(json['title'])),
  originalUrl: OriginalUrl.fromJson(
    const StringConverter().fromJson(json['originalUrl']),
  ),
  index: const IndexConverter().fromJson(json['index']),
  contentType: const ContentTypeConverter().fromJson(json['contentType']),
  content: json['content'] == null
      ? null
      : ChapterContent.fromJson(
          const StringConverter().fromJson(json['content']),
        ),
  contentFormat: const ContentFormatConverter().fromJson(json['contentFormat']),
  documentPath: json['documentPath'] == null
      ? null
      : DocumentPath.fromJson(
          const StringConverter().fromJson(json['documentPath']),
        ),
  documentFormat: const DocumentFormatConverter().fromJson(
    json['documentFormat'],
  ),
  scrapingStatus: const ScrapingStatusConverter().fromJson(
    json['scrapingStatus'],
  ),
  retries: PositiveInt.fromJson(const IntConverter().fromJson(json['retries'])),
  isFinal: json['isFinal'] as bool? ?? false,
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
  previous: json['previous'] == null
      ? null
      : ChapterId.fromJson(const StringConverter().fromJson(json['previous'])),
  next: json['next'] == null
      ? null
      : ChapterId.fromJson(const StringConverter().fromJson(json['next'])),
  bookId: BookId.fromJson(const StringConverter().fromJson(json['bookId'])),
  bookTitle: BookTitle.fromJson(
    const StringConverter().fromJson(json['bookTitle']),
  ),
  totalChapters: PositiveInt.fromJson(
    const IntConverter().fromJson(json['totalChapters']),
  ),
  pages: const ReadingPageListConverter().fromJson(json['pages'] as List?),
  comments: const ChapterCommentListConverter().fromJson(
    json['comments'] as List?,
  ),
);

Map<String, dynamic> _$ReadingChapterModelToJson(
  ReadingChapterModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'originalUrl': instance.originalUrl,
  'index': const IndexConverter().toJson(instance.index),
  'contentType': const ContentTypeConverter().toJson(instance.contentType),
  'content': instance.content,
  'contentFormat': const ContentFormatConverter().toJson(
    instance.contentFormat,
  ),
  'documentPath': instance.documentPath,
  'documentFormat': const DocumentFormatConverter().toJson(
    instance.documentFormat,
  ),
  'scrapingStatus': const ScrapingStatusConverter().toJson(
    instance.scrapingStatus,
  ),
  'retries': instance.retries,
  'isFinal': instance.isFinal,
  'deletedAt': instance.deletedAt?.toIso8601String(),
  'previous': instance.previous,
  'next': instance.next,
  'bookId': instance.bookId,
  'bookTitle': instance.bookTitle,
  'totalChapters': instance.totalChapters,
  'pages': const ReadingPageListConverter().toJson(instance.pages),
  'comments': const ChapterCommentListConverter().toJson(instance.comments),
};
