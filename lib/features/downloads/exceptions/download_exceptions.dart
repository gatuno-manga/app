import '../../../core/exceptions/exceptions.dart';

/// The server has no such chapter (HTTP 404), or it has no content to
/// download yet.
class ChapterUnavailableException extends AppExceptions {
  ChapterUnavailableException(String chapterId)
    : super('Chapter $chapterId has nothing to download', statusCode: 404);
}

/// The device did not save a book type's download network rule.
class NetworkRuleNotSavedException extends AppExceptions {
  NetworkRuleNotSavedException(String bookType)
    : super('The network rule of $bookType was not saved');
}

/// The server asked to try again later (rate limit, gateway error).
class TransientServerException extends AppExceptions {
  TransientServerException(int statusCode)
    : super('Server busy (HTTP $statusCode)', statusCode: statusCode);
}
