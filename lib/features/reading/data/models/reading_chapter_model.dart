import '../../domain/entities/reading_chapter.dart';
import '../../domain/entities/reading_enums.dart';
import '../../../books/domain/entities/chapter.dart';

class ReadingPageModel extends ReadingPage {
  const ReadingPageModel({
    required super.id,
    required super.url,
    required super.index,
  });

  factory ReadingPageModel.fromJson(Map<String, dynamic> json) {
    return ReadingPageModel(
      id: json['id'] as String,
      url: json['url'] as String,
      index: (json['index'] as num).toInt(),
    );
  }
}

class ChapterCommentModel extends ChapterComment {
  const ChapterCommentModel({
    required super.id,
    required super.content,
    required super.createdAt,
    required super.userId,
    required super.userName,
  });

  factory ChapterCommentModel.fromJson(Map<String, dynamic> json) {
    return ChapterCommentModel(
      id: json['id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userId: json['userId'] as String,
      userName: json['userName'] as String,
    );
  }
}

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
    required super.isFinal,
    super.deletedAt,
    super.previous,
    super.next,
    required super.bookId,
    required super.bookTitle,
    required super.totalChapters,
    required super.pages,
    required super.comments,
  });

  factory ReadingChapterModel.fromJson(Map<String, dynamic> json) {
    return ReadingChapterModel(
      id: json['id'] as String,
      title: json['title'] as String?,
      originalUrl: json['originalUrl'] as String,
      index: (json['index'] as num).toDouble(),
      contentType: ContentType.fromString(json['contentType'] as String),
      content: json['content'] as String?,
      contentFormat: json['contentFormat'] != null
          ? ContentFormat.fromString(json['contentFormat'] as String)
          : null,
      documentPath: json['documentPath'] as String?,
      documentFormat: json['documentFormat'] != null
          ? DocumentFormat.fromString(json['documentFormat'] as String)
          : null,
      scrapingStatus: _parseScrapingStatus(json['scrapingStatus'] as String?),
      retries: (json['retries'] as num? ?? 0).toInt(),
      isFinal: json['isFinal'] as bool? ?? false,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
      previous: json['previous'] as String?,
      next: json['next'] as String?,
      bookId: json['bookId'] as String,
      bookTitle: json['bookTitle'] as String,
      totalChapters: (json['totalChapters'] as num? ?? 0).toInt(),
      pages: (json['pages'] as List<dynamic>? ?? [])
          .map((e) => ReadingPageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      comments: (json['comments'] as List<dynamic>? ?? [])
          .map((e) => ChapterCommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

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
}
