import '../../../../shared/domain/entities/image_metadata.dart';
import 'reading_enums.dart';
import '../../../../features/books/domain/entities/chapter.dart';

class ReadingPage {
  final String id;
  final String url;
  final int index;
  final ImageMetadata? metadata;

  const ReadingPage({
    required this.id,
    required this.url,
    required this.index,
    this.metadata,
  });

  double? get width => metadata?.width;
  double? get height => metadata?.height;
}

class ChapterComment {
  final String id;
  final String content;
  final DateTime createdAt;
  final String userId;
  final String userName;

  const ChapterComment({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.userId,
    required this.userName,
  });
}

class ReadingChapter {
  final String id;
  final String? title;
  final String originalUrl;
  final double index;
  final ContentType contentType;
  final String? content;
  final ContentFormat? contentFormat;
  final String? documentPath;
  final DocumentFormat? documentFormat;
  final ScrapingStatus? scrapingStatus;
  final int retries;
  final bool isFinal;
  final DateTime? deletedAt;
  final String? previous;
  final String? next;
  final String bookId;
  final String bookTitle;
  final int totalChapters;
  final List<ReadingPage> pages;
  final List<ChapterComment> comments;

  const ReadingChapter({
    required this.id,
    this.title,
    required this.originalUrl,
    required this.index,
    required this.contentType,
    this.content,
    this.contentFormat,
    this.documentPath,
    this.documentFormat,
    this.scrapingStatus,
    required this.retries,
    required this.isFinal,
    this.deletedAt,
    this.previous,
    this.next,
    required this.bookId,
    required this.bookTitle,
    required this.totalChapters,
    required this.pages,
    required this.comments,
  });
}
