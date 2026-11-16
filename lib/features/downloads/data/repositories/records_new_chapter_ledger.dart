import '../../../books/domain/value_objects/book_id.dart';
import '../../../books/domain/value_objects/chapter_id.dart';
import '../../domain/entities/auto_download_check_state.dart';
import '../../domain/repositories/new_chapter_ledger.dart';
import '../data_sources/download_records.dart';

/// [NewChapterLedger] on the downloads database, next to the setting itself,
/// so turning it off and a server change clear it too.
class RecordsNewChapterLedger implements NewChapterLedger {
  final DownloadRecords _records;

  RecordsNewChapterLedger(this._records);

  @override
  Future<List<AutoDownloadCheckState>> books() async => [
    for (final row in await _records.autoDownloadChecks())
      AutoDownloadCheckState(
        bookId: BookId(row.bookId),
        since: row.autoDownloadSince!,
        hasBaseline: row.autoDownloadBaselineFor == row.autoDownloadSince,
        checkedAt: row.autoDownloadCheckedAt,
      ),
  ];

  @override
  Future<Set<ChapterId>> seen(BookId bookId) async => {
    for (final id in await _records.seenChapters(bookId.value)) ChapterId(id),
  };

  @override
  Future<bool> record(
    AutoDownloadCheckState book, {
    required Set<ChapterId> chapters,
    required bool baseline,
    required DateTime at,
  }) => _records.recordAutoDownloadCheck(
    book.bookId.value,
    since: book.since,
    chapters: {for (final id in chapters) id.value},
    baseline: baseline,
    at: at,
  );

  @override
  Future<bool> isCurrent(AutoDownloadCheckState book) async =>
      await _records.autoDownloadSince(book.bookId.value) == book.since;
}
