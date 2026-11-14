import '../../../core/exceptions/exceptions.dart';

/// The server has no such chapter (HTTP 404), or it has no content to
/// download yet.
class ChapterUnavailableException extends AppExceptions {
  ChapterUnavailableException(String chapterId)
    : super('Chapter $chapterId has nothing to download', statusCode: 404);
}
