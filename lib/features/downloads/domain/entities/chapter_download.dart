import 'package:equatable/equatable.dart';

import '../../../books/domain/value_objects/book_id.dart';
import '../../../books/domain/value_objects/chapter_id.dart';
import 'download_state.dart';

/// The download of one chapter.
class ChapterDownload extends Equatable {
  final ChapterId chapterId;
  final BookId bookId;
  final DownloadState state;
  final DownloadWaitReason reason;

  /// Files on disk, out of [filesTotal]. Both are 0 until the chapter's
  /// manifest is fetched; a text chapter has no files besides its manifest.
  final int filesDone;
  final int filesTotal;

  /// Bytes on disk, manifest included.
  final int bytes;

  /// A [DownloadErrors] code when [state] is [DownloadState.failed].
  final String? error;

  const ChapterDownload({
    required this.chapterId,
    required this.bookId,
    required this.state,
    this.reason = DownloadWaitReason.none,
    this.filesDone = 0,
    this.filesTotal = 0,
    this.bytes = 0,
    this.error,
  });

  /// From 0 to 1. A done chapter is 1 even with no files.
  double get progress {
    if (state == DownloadState.done) return 1;
    if (filesTotal == 0) return 0;
    return filesDone / filesTotal;
  }

  @override
  List<Object?> get props => [
    chapterId,
    bookId,
    state,
    reason,
    filesDone,
    filesTotal,
    bytes,
    error,
  ];
}
