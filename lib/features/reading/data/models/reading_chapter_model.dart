import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/reading_chapter.dart';
import '../../domain/entities/reading_enums.dart';
import '../../../books/domain/entities/chapter.dart';

import '../../../../shared/data/models/image_metadata_model.dart';
import '../../../../shared/domain/value_objects/positive_int.dart';
import '../../../../features/books/domain/value_objects/book_id.dart';
import '../../../../features/books/domain/value_objects/book_title.dart';
import '../../../../features/books/domain/value_objects/chapter_id.dart';
import '../../../../features/books/domain/value_objects/chapter_index.dart';
import '../../../../features/books/domain/value_objects/chapter_title.dart';
import '../../../../features/users/domain/value_objects/user_display_name.dart';
import '../../../../features/users/domain/value_objects/user_id.dart';
import '../../domain/value_objects/chapter_content.dart';
import '../../domain/value_objects/comment_content.dart';
import '../../domain/value_objects/comment_id.dart';
import '../../domain/value_objects/document_path.dart';
import '../../domain/value_objects/original_url.dart';
import '../../domain/value_objects/reading_page_id.dart';
import '../../domain/value_objects/reading_page_url.dart';
import '../../../../shared/domain/value_objects/timestamp.dart';

part 'reading_chapter_model.g.dart';

class IntConverter implements JsonConverter<int, dynamic> {
  const IntConverter();
  @override
  int fromJson(dynamic json) => int.tryParse(json?.toString() ?? '0') ?? 0;
  @override
  dynamic toJson(int object) => object;
}

class IndexConverter implements JsonConverter<ChapterIndex, dynamic> {
  const IndexConverter();
  @override
  ChapterIndex fromJson(dynamic json) {
    if (json == null) return const ChapterIndex(0.0);
    if (json is num) return ChapterIndex(json.toDouble());
    return ChapterIndex(double.tryParse(json.toString()) ?? 0.0);
  }

  @override
  dynamic toJson(ChapterIndex object) => object.value;
}

class StringConverter implements JsonConverter<String, dynamic> {
  const StringConverter();
  @override
  String fromJson(dynamic json) => json?.toString() ?? '';
  @override
  dynamic toJson(String object) => object;
}

class ContentTypeConverter implements JsonConverter<ContentType, dynamic> {
  const ContentTypeConverter();
  @override
  ContentType fromJson(dynamic json) =>
      ContentType.fromString(json?.toString() ?? '');
  @override
  dynamic toJson(ContentType object) => object.value;
}

class ContentFormatConverter implements JsonConverter<ContentFormat?, dynamic> {
  const ContentFormatConverter();
  @override
  ContentFormat? fromJson(dynamic json) =>
      json != null ? ContentFormat.fromString(json.toString()) : null;
  @override
  dynamic toJson(ContentFormat? object) => object?.value;
}

class DocumentFormatConverter
    implements JsonConverter<DocumentFormat?, dynamic> {
  const DocumentFormatConverter();
  @override
  DocumentFormat? fromJson(dynamic json) =>
      json != null ? DocumentFormat.fromString(json.toString()) : null;
  @override
  dynamic toJson(DocumentFormat? object) => object?.value;
}

class ScrapingStatusConverter
    implements JsonConverter<ScrapingStatus?, dynamic> {
  const ScrapingStatusConverter();
  @override
  ScrapingStatus? fromJson(dynamic json) {
    if (json == null) return null;
    final statusStr = json.toString();
    try {
      return ScrapingStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == statusStr.toLowerCase(),
      );
    } catch (_) {
      return ScrapingStatus.process;
    }
  }

  @override
  dynamic toJson(ScrapingStatus? object) => object?.name;
}

@JsonSerializable(converters: [IntConverter(), StringConverter()])
class ReadingPageModel extends ReadingPage {
  @JsonKey(name: 'metadata')
  final ImageMetadataModel? imageMetadata;

  ReadingPageModel({
    required super.id,
    @JsonKey(readValue: _readUrl) required super.url,
    required super.index,
    this.imageMetadata,
  }) : super(metadata: imageMetadata);

  factory ReadingPageModel.fromJson(Map<String, dynamic> json) =>
      _$ReadingPageModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReadingPageModelToJson(this);

  static Object? _readUrl(Map<dynamic, dynamic> json, String key) =>
      json['path'] ?? json['url'] ?? '';
}

@JsonSerializable(converters: [StringConverter()])
class ChapterCommentModel extends ChapterComment {
  const ChapterCommentModel({
    required super.id,
    required super.content,
    required super.createdAt,
    required super.userId,
    required super.userName,
  });

  factory ChapterCommentModel.fromJson(Map<String, dynamic> json) =>
      _$ChapterCommentModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChapterCommentModelToJson(this);
}

class ReadingPageListConverter
    implements JsonConverter<List<ReadingPage>, List<dynamic>?> {
  const ReadingPageListConverter();
  @override
  List<ReadingPage> fromJson(List<dynamic>? json) {
    return (json ?? [])
        .map((e) => ReadingPageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  List<dynamic> toJson(List<ReadingPage> object) {
    return object.map((e) => (e as ReadingPageModel).toJson()).toList();
  }
}

class ChapterCommentListConverter
    implements JsonConverter<List<ChapterComment>, List<dynamic>?> {
  const ChapterCommentListConverter();
  @override
  List<ChapterComment> fromJson(List<dynamic>? json) {
    return (json ?? [])
        .map((e) => ChapterCommentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  List<dynamic> toJson(List<ChapterComment> object) {
    return object.map((e) => (e as ChapterCommentModel).toJson()).toList();
  }
}

@JsonSerializable(
  converters: [
    ReadingPageListConverter(),
    ChapterCommentListConverter(),
    StringConverter(),
    IndexConverter(),
    IntConverter(),
    ContentTypeConverter(),
    ContentFormatConverter(),
    DocumentFormatConverter(),
    ScrapingStatusConverter(),
  ],
)
class ReadingChapterModel extends ReadingChapter {
  const ReadingChapterModel({
    required super.id,
    super.title,
    required super.originalUrl,
    required super.index,
    required super.contentType,
    super.content,
    super.contentFormat,
    super.documentPath,
    super.documentFormat,
    super.scrapingStatus,
    required super.retries,
    @JsonKey(defaultValue: false) required super.isFinal,
    super.deletedAt,
    super.previous,
    super.next,
    required super.bookId,
    required super.bookTitle,
    required super.totalChapters,
    required super.pages,
    required super.comments,
  });

  factory ReadingChapterModel.fromJson(Map<String, dynamic> json) =>
      _$ReadingChapterModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReadingChapterModelToJson(this);
}
