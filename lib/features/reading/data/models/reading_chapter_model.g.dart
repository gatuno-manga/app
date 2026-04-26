// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_chapter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadingPageModel _$ReadingPageModelFromJson(Map<String, dynamic> json) =>
    ReadingPageModel(
      id: ReadingPageModel._parseString(json['id']),
      url: ReadingPageModel._readUrl(json, 'url') as String,
      index: ReadingPageModel._parseInt(json['index']),
      pageMetadata: json['metadata'] == null
          ? null
          : PageMetadataModel.fromJson(
              json['metadata'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ReadingPageModelToJson(ReadingPageModel instance) =>
    <String, dynamic>{
      'url': instance.url,
      'id': instance.id,
      'index': instance.index,
      'metadata': instance.pageMetadata,
    };

PageMetadataModel _$PageMetadataModelFromJson(Map<String, dynamic> json) =>
    PageMetadataModel(
      width: PageMetadataModel._parseDouble(json['width']),
      height: PageMetadataModel._parseDouble(json['height']),
    );

Map<String, dynamic> _$PageMetadataModelToJson(PageMetadataModel instance) =>
    <String, dynamic>{'width': instance.width, 'height': instance.height};

ChapterCommentModel _$ChapterCommentModelFromJson(Map<String, dynamic> json) =>
    ChapterCommentModel(
      id: ChapterCommentModel._parseString(json['id']),
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userId: ChapterCommentModel._parseString(json['userId']),
      userName: json['userName'] as String,
    );

Map<String, dynamic> _$ChapterCommentModelToJson(
  ChapterCommentModel instance,
) => <String, dynamic>{
  'content': instance.content,
  'createdAt': instance.createdAt.toIso8601String(),
  'userName': instance.userName,
  'id': instance.id,
  'userId': instance.userId,
};

ReadingChapterModel _$ReadingChapterModelFromJson(Map<String, dynamic> json) =>
    ReadingChapterModel(
      id: ReadingChapterModel._parseString(json['id']),
      title: json['title'] as String?,
      originalUrl: json['originalUrl'] as String,
      index: ReadingChapterModel._parseDouble(json['index']),
      contentType: ContentType.fromString(json['contentType'] as String),
      content: json['content'] as String?,
      contentFormat: ReadingChapterModel._parseContentFormat(
        json['contentFormat'] as String?,
      ),
      documentPath: json['documentPath'] as String?,
      documentFormat: ReadingChapterModel._parseDocumentFormat(
        json['documentFormat'] as String?,
      ),
      scrapingStatus: ReadingChapterModel._parseScrapingStatus(
        json['scrapingStatus'] as String?,
      ),
      retries: ReadingChapterModel._parseInt(json['retries']),
      isFinal: json['isFinal'] as bool? ?? false,
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      previous: json['previous'] as String?,
      next: json['next'] as String?,
      bookId: ReadingChapterModel._parseString(json['bookId']),
      bookTitle: json['bookTitle'] as String,
      totalChapters: ReadingChapterModel._parseInt(json['totalChapters']),
      pages:
          (json['pages'] as List<dynamic>?)
              ?.map((e) => ReadingPageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map(
                (e) => ChapterCommentModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );

Map<String, dynamic> _$ReadingChapterModelToJson(
  ReadingChapterModel instance,
) => <String, dynamic>{
  'title': instance.title,
  'originalUrl': instance.originalUrl,
  'content': instance.content,
  'documentPath': instance.documentPath,
  'isFinal': instance.isFinal,
  'deletedAt': instance.deletedAt?.toIso8601String(),
  'previous': instance.previous,
  'next': instance.next,
  'bookTitle': instance.bookTitle,
  'id': instance.id,
  'bookId': instance.bookId,
  'pages': instance.pages,
  'comments': instance.comments,
  'index': instance.index,
  'contentType': _$ContentTypeEnumMap[instance.contentType]!,
  'contentFormat': _$ContentFormatEnumMap[instance.contentFormat],
  'documentFormat': _$DocumentFormatEnumMap[instance.documentFormat],
  'scrapingStatus': _$ScrapingStatusEnumMap[instance.scrapingStatus],
  'retries': instance.retries,
  'totalChapters': instance.totalChapters,
};

const _$ContentTypeEnumMap = {
  ContentType.image: 'image',
  ContentType.text: 'text',
  ContentType.document: 'document',
};

const _$ContentFormatEnumMap = {
  ContentFormat.markdown: 'markdown',
  ContentFormat.html: 'html',
  ContentFormat.plain: 'plain',
};

const _$DocumentFormatEnumMap = {
  DocumentFormat.pdf: 'pdf',
  DocumentFormat.epub: 'epub',
};

const _$ScrapingStatusEnumMap = {
  ScrapingStatus.process: 'process',
  ScrapingStatus.ready: 'ready',
  ScrapingStatus.error: 'error',
};
