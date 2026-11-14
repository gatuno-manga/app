import 'package:equatable/equatable.dart';

import '../../../books/domain/value_objects/book_id.dart';
import 'chapter_download.dart';
import 'download_state.dart';

/// Every chapter download of one book, in enqueue order.
class BookDownload extends Equatable {
  final BookId bookId;
  final List<ChapterDownload> chapters;

  const BookDownload({required this.bookId, required this.chapters});

  /// How many chapters are in [state].
  int count(DownloadState state) =>
      chapters.where((c) => c.state == state).length;

  int get bytes => chapters.fold(0, (sum, c) => sum + c.bytes);

  /// Mean of the chapters' progress, from 0 to 1.
  double get progress {
    if (chapters.isEmpty) return 0;
    return chapters.fold<double>(0, (sum, c) => sum + c.progress) /
        chapters.length;
  }

  @override
  List<Object?> get props => [bookId, chapters];
}
