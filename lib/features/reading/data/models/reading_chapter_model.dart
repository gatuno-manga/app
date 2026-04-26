import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/reading_chapter.dart';
import '../../domain/entities/reading_enums.dart';
import '../../../books/domain/entities/chapter.dart';

part 'reading_chapter_model.g.dart';

@JsonSerializable()
class ReadingPageModel extends ReadingPage {
  @override
  @JsonKey(fromJson: _parseString)
  final String id;

  @override
  @JsonKey(fromJson: _parseInt)
  final int index;

  @JsonKey(name: 'metadata')
  final PageMetadataModel? pageMetadata;

  ReadingPageModel({
    required this.id,
    @JsonKey(readValue: _readUrl) required super.url,
    required this.index,
    this.pageMetadata,
  }) : super(
          id: id,
          index: index,
          width: pageMetadata?.width,
          height: pageMetadata?.height,
        );

  factory ReadingPageModel.fromJson(Map<String, dynamic> json) =>
      _$ReadingPageModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReadingPageModelToJson(this);

  static Object? _readUrl(Map json, String key) =>
      json['path'] ?? json['url'] ?? '';

  static int _parseInt(dynamic value) =>
      int.tryParse(value?.toString() ?? '0') ?? 0;

  static String _parseString(dynamic value) => value?.toString() ?? '';
}

@JsonSerializable()
class PageMetadataModel {
  @JsonKey(fromJson: _parseDouble)
  final double width;
  @JsonKey(fromJson: _parseDouble)
  final double height;

  PageMetadataModel({
    required this.width,
    required this.height,
  });

  factory PageMetadataModel.fromJson(Map<String, dynamic> json) =>
      _$PageMetadataModelFromJson(json);

  Map<String, dynamic> toJson() => _$PageMetadataModelToJson(this);

  static double _parseDouble(dynamic value) =>
      double.tryParse(value?.toString() ?? '0') ?? 0.0;
}

@JsonSerializable()
class ChapterCommentModel extends ChapterComment {
  @override
  @JsonKey(fromJson: _parseString)
  final String id;

  @override
  @JsonKey(fromJson: _parseString)
  final String userId;

  ChapterCommentModel({
    required this.id,
    required super.content,
    required super.createdAt,
    required this.userId,
    required super.userName,
  }) : super(id: id, userId: userId);

  factory ChapterCommentModel.fromJson(Map<String, dynamic> json) =>
      _$ChapterCommentModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChapterCommentModelToJson(this);

  static String _parseString(dynamic value) => value?.toString() ?? '';
}

@JsonSerializable()
class ReadingChapterModel extends ReadingChapter {
  @override
  @JsonKey(fromJson: _parseString)
  final String id;

  @override
  @JsonKey(fromJson: _parseString)
  final String bookId;

  @override
  @JsonKey(defaultValue: [])
  final List<ReadingPageModel> pages;

  @override
  @JsonKey(defaultValue: [])
  final List<ChapterCommentModel> comments;

  @override
  @JsonKey(fromJson: _parseDouble)
  final double index;

  @override
  @JsonKey(fromJson: ContentType.fromString)
  final ContentType contentType;

  @override
  @JsonKey(fromJson: _parseContentFormat)
  final ContentFormat? contentFormat;

  @override
  @JsonKey(fromJson: _parseDocumentFormat)
  final DocumentFormat? documentFormat;

  @override
  @JsonKey(fromJson: _parseScrapingStatus)
  final ScrapingStatus? scrapingStatus;

  @override
  @JsonKey(fromJson: _parseInt)
  final int retries;

  @override
  @JsonKey(fromJson: _parseInt)
  final int totalChapters;

  ReadingChapterModel({
    required this.id,
    super.title,
    required super.originalUrl,
    required this.index,
    required this.contentType,
    super.content,
    this.contentFormat,
    super.documentPath,
    this.documentFormat,
    this.scrapingStatus,
    required this.retries,
    @JsonKey(defaultValue: false) required super.isFinal,
    super.deletedAt,
    super.previous,
    super.next,
    required this.bookId,
    required super.bookTitle,
    required this.totalChapters,
    required this.pages,
    required this.comments,
  }) : super(
          id: id,
          bookId: bookId,
          index: index,
          contentType: contentType,
          contentFormat: contentFormat,
          documentFormat: documentFormat,
          scrapingStatus: scrapingStatus,
          retries: retries,
          totalChapters: totalChapters,
          pages: pages,
          comments: comments,
        );

  factory ReadingChapterModel.fromJson(Map<String, dynamic> json) =>
      _$ReadingChapterModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReadingChapterModelToJson(this);

  static ContentFormat? _parseContentFormat(String? value) =>
      value != null ? ContentFormat.fromString(value) : null;

  static DocumentFormat? _parseDocumentFormat(String? value) =>
      value != null ? DocumentFormat.fromString(value) : null;

  static ScrapingStatus? _parseScrapingStatus(String? status) {
    if (status == null) return null;
    try {
      return ScrapingStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == status.toLowerCase(),
      );
    } catch (_) {
      return ScrapingStatus.process;
    }
  }

  static double _parseDouble(dynamic value) =>
      double.tryParse(value?.toString() ?? '0') ?? 0.0;

  static int _parseInt(dynamic value) =>
      int.tryParse(value?.toString() ?? '0') ?? 0;

  static String _parseString(dynamic value) => value?.toString() ?? '';
}
