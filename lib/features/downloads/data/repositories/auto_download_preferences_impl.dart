import '../../../books/domain/value_objects/book_id.dart';
import '../../domain/entities/auto_download.dart';
import '../../domain/repositories/auto_download_preferences.dart';
import '../data_sources/download_records.dart';

/// Keeps the setting on the book's row of the downloads database, so a
/// server change wipes it with the downloads.
class AutoDownloadPreferencesImpl implements AutoDownloadPreferences {
  final DownloadRecords _records;
  final DateTime Function() _now;

  AutoDownloadPreferencesImpl(
    this._records, {
    DateTime Function() now = DateTime.now,
  }) : _now = now;

  @override
  Stream<AutoDownload?> watch(BookId bookId) => _records
      .watchAutoDownloadSince(bookId.value)
      .map(
        (since) =>
            since == null ? null : AutoDownload(bookId: bookId, since: since),
      );

  @override
  Future<void> enable(BookId bookId) =>
      _records.enableAutoDownload(bookId.value, _now());

  @override
  Future<void> disable(BookId bookId) =>
      _records.disableAutoDownload(bookId.value);

  @override
  Future<List<AutoDownload>> enabledBooks() async => [
    for (final row in await _records.autoDownloadBooks())
      AutoDownload(bookId: BookId(row.bookId), since: row.since),
  ];
}
