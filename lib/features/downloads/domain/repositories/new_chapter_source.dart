import '../../../books/domain/value_objects/book_id.dart';
import '../entities/listed_chapter.dart';

/// Lists the chapters of several books at once, for the new-chapter check.
abstract class NewChapterSource {
  /// The most books one [chaptersOf] call takes.
  static const int maxBooks = 50;

  /// Every chapter of each of [bookIds] (at most [maxBooks]), by book. A book
  /// the server did not return (deleted, or hidden from this user) is
  /// missing from the map.
  Future<Map<BookId, List<ListedChapter>>> chaptersOf(List<BookId> bookIds);
}
