import '../../../books/domain/value_objects/book_id.dart';
import '../entities/auto_download.dart';

/// Per-book "download new chapters automatically".
///
/// The book details page writes it; the new-chapter check reads
/// [enabledBooks] to pick the books to check, and uses
/// [AutoDownload.since] to tell new chapters from old ones. Turning it on
/// downloads nothing by itself. Deleting a book's downloads keeps it; a
/// server change clears it with the downloads.
abstract class AutoDownloadPreferences {
  /// The setting of [bookId], `null` while it is off. Emits on listen, then
  /// on every change.
  Stream<AutoDownload?> watch(BookId bookId);

  /// Turns it on for [bookId], with `since` set to now (also when it was
  /// already on).
  Future<void> enable(BookId bookId);

  /// Turns it off for [bookId].
  Future<void> disable(BookId bookId);

  /// Every book with it on, oldest setting first.
  Future<List<AutoDownload>> enabledBooks();
}
