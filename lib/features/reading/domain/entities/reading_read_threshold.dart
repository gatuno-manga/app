/// Shared threshold for treating chapter reading progress as read.
const double chapterReadThreshold = 0.8;

/// Whether [completed] or visual page progress (`>= 80%`) counts as read.
bool isChapterReadProgress({
  required int pageIndex,
  required int totalPages,
  required bool completed,
}) {
  if (completed) return true;
  return totalPages > 0 && (pageIndex + 1) / totalPages >= chapterReadThreshold;
}
