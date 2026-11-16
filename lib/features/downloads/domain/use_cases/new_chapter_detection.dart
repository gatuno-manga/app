import '../../../books/domain/value_objects/chapter_id.dart';
import '../entities/listed_chapter.dart';

/// What one book's check does with the chapters the server listed.
class NewChapterDecision {
  /// New ready chapters to download, in the server's order.
  final List<ChapterId> queue;

  /// Chapters to add to the seen set.
  final Set<ChapterId> record;

  const NewChapterDecision({required this.queue, required this.record});
}

/// Picks the chapters of one book to download automatically.
///
/// Without a baseline, every listed chapter is recorded and none is queued:
/// chapters that existed when automatic download was turned on are
/// downloaded by hand. Afterwards a chapter not [seen] is new: it is queued
/// once ready and recorded then; one still being scraped waits for a later
/// check. A new chapter that already has a download ([downloaded], queued by
/// hand or paused) is only recorded, so the check never resumes it.
NewChapterDecision decideNewChapters({
  required List<ListedChapter> listed,
  required Set<ChapterId> seen,
  required Set<ChapterId> downloaded,
  required bool hasBaseline,
}) {
  if (!hasBaseline) {
    return NewChapterDecision(
      queue: const [],
      record: {for (final chapter in listed) chapter.id},
    );
  }
  final queue = <ChapterId>[];
  final record = <ChapterId>{};
  for (final chapter in listed) {
    if (seen.contains(chapter.id)) continue;
    if (downloaded.contains(chapter.id)) {
      record.add(chapter.id);
    } else if (chapter.ready && record.add(chapter.id)) {
      queue.add(chapter.id);
    }
  }
  return NewChapterDecision(queue: queue, record: record);
}
