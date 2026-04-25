import '../../domain/entities/reading_chapter.dart';
import '../../domain/entities/reading_enums.dart';
import '../../../books/domain/entities/chapter.dart';

class ReadingPageModel extends ReadingPage {
  const ReadingPageModel({
    required super.id,
    required super.url,
    required super.index,
    super.width,
    super.height,
  });

  factory ReadingPageModel.fromJson(Map<String, dynamic> json) {
    return ReadingPageModel(
      id: json['id']?.toString() ?? '',
      url: (json['path'] ?? json['url'])?.toString() ?? '',
      index: int.tryParse(json['index']?.toString() ?? '0') ?? 0,
      width: double.tryParse(json['metadata']?['width']?.toString() ?? ''),
      height: double.tryParse(json['metadata']?['height']?.toString() ?? ''),
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
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
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
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString(),
      originalUrl: json['originalUrl']?.toString() ?? '',
      index: double.tryParse(json['index']?.toString() ?? '0') ?? 0.0,
      contentType: ContentType.fromString(
        json['contentType']?.toString() ?? '',
      ),
      content: json['content']?.toString(),
      contentFormat: json['contentFormat'] != null
          ? ContentFormat.fromString(json['contentFormat']?.toString() ?? '')
          : null,
      documentPath: json['documentPath']?.toString(),
      documentFormat: json['documentFormat'] != null
          ? DocumentFormat.fromString(json['documentFormat']?.toString() ?? '')
          : null,
      scrapingStatus: _parseScrapingStatus(json['scrapingStatus']?.toString()),
      retries: int.tryParse(json['retries']?.toString() ?? '0') ?? 0,
      isFinal: json['isFinal'] as bool? ?? false,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
      previous: json['previous']?.toString(),
      next: json['next']?.toString(),
      bookId: json['bookId']?.toString() ?? '',
      bookTitle: json['bookTitle']?.toString() ?? '',
      totalChapters:
          int.tryParse(json['totalChapters']?.toString() ?? '0') ?? 0,
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
