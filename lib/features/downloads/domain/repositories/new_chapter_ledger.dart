import '../../../books/domain/value_objects/book_id.dart';
import '../../../books/domain/value_objects/chapter_id.dart';
import '../entities/auto_download_check_state.dart';

/// What the new-chapter check remembers per book with automatic download
/// on: the chapters it has seen and when it last looked. Cleared when
/// automatic download is turned off and with the downloads on a server
/// change.
abstract class NewChapterLedger {
  /// Books with automatic download on, never checked first, then the least
  /// recently checked.
  Future<List<AutoDownloadCheckState>> books();

  /// Chapters seen for [bookId]: never queued automatically.
  Future<Set<ChapterId>> seen(BookId bookId);

  /// Records a check of [book] at [at]: [chapters] join its seen set, or
  /// replace it when [baseline]. Writes nothing and returns `false` when
  /// automatic download is no longer on from `book.since` (turned off or on
  /// again meanwhile, or the downloads were wiped).
  Future<bool> record(
    AutoDownloadCheckState book, {
    required Set<ChapterId> chapters,
    required bool baseline,
    required DateTime at,
  });

  /// When any book was last checked; `null` if never.
  Future<DateTime?> lastCheck();
}
