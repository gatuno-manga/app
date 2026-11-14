import 'dart:io';

/// Book covers kept on disk, in storage the app controls (the OS does not
/// clear it), so covers render offline.
///
/// Keyed by book id. A cover is fetched the first time it is displayed and
/// served from disk from then on, even online; it is replaced when the book's
/// cover URL changes. Unpinned covers share a size budget and are evicted
/// least recently used first. A pin (for example owner `download`) keeps a
/// cover, and the book's cached row, until every owner unpins it.
abstract class CoverStore {
  /// The stored cover of [bookId], or `null` when none is stored.
  Future<File?> file(String bookId);

  /// The stored cover of [bookId] for [sourceUrl], downloading it when it is
  /// missing or was stored for another URL. `null` when it cannot be fetched
  /// (offline, server error) and nothing is stored.
  Future<File?> ensure(String bookId, String sourceUrl);

  /// The book whose cached cover URL is [sourceUrl], if the cache knows one.
  Future<String?> bookIdForUrl(String sourceUrl);

  Future<void> pin(String bookId, String owner);

  Future<void> unpin(String bookId, String owner);

  /// Deletes the covers of [bookIds], pinned or not.
  Future<void> remove(Iterable<String> bookIds);

  /// Evicts unpinned covers, least recently used first, until they fit the
  /// budget.
  Future<void> enforceBudget();

  /// Deletes every stored cover and pin.
  Future<void> clear();
}
