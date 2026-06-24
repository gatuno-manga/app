import '../../../../shared/domain/entities/image_metadata.dart';
import 'reading_enums.dart';
import '../../../../features/books/domain/entities/chapter.dart';
import '../../../../features/books/domain/value_objects/book_id.dart';
import '../../../../features/books/domain/value_objects/book_title.dart';
import '../../../../features/books/domain/value_objects/chapter_id.dart';
import '../../../../features/books/domain/value_objects/chapter_index.dart';
import '../../../../features/books/domain/value_objects/chapter_title.dart';
import '../../../../features/users/domain/value_objects/user_display_name.dart';
import '../../../../features/users/domain/value_objects/user_id.dart';
import '../../../../shared/domain/value_objects/positive_int.dart';
import '../../../../shared/domain/value_objects/timestamp.dart';
import '../value_objects/chapter_content.dart';
import '../value_objects/comment_content.dart';
import '../value_objects/comment_id.dart';
import '../value_objects/document_path.dart';
import '../value_objects/original_url.dart';
import '../value_objects/reading_page_id.dart';
import '../value_objects/reading_page_url.dart';

class ReadingPage {
  final ReadingPageId id;
  final ReadingPageUrl url;
  final PositiveInt index;
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
  final CommentId id;
  final CommentContent content;
  final Timestamp createdAt;
  final UserId userId;
  final UserDisplayName userName;

  const ChapterComment({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.userId,
    required this.userName,
  });
}

class ReadingChapter {
  final ChapterId id;
  final ChapterTitle? title;
  final OriginalUrl originalUrl;
  final ChapterIndex index;
  final ContentType contentType;
  final ChapterContent? content;
  final ContentFormat? contentFormat;
  final DocumentPath? documentPath;
  final DocumentFormat? documentFormat;
  final ScrapingStatus? scrapingStatus;
  final PositiveInt retries;
  final bool isFinal;
  final DateTime? deletedAt;
  final ChapterId? previous;
  final ChapterId? next;
  final BookId bookId;
  final BookTitle bookTitle;
  final PositiveInt totalChapters;
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
