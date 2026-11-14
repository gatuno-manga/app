import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/downloads/domain/entities/book_download.dart';
import 'package:gatuno/features/downloads/domain/entities/chapter_download.dart';
import 'package:gatuno/features/downloads/domain/entities/download_state.dart';

ChapterDownload chapter(
  String id,
  DownloadState state, {
  int done = 0,
  int total = 0,
  int bytes = 0,
}) => ChapterDownload(
  chapterId: ChapterId(id),
  bookId: const BookId('b'),
  state: state,
  filesDone: done,
  filesTotal: total,
  bytes: bytes,
);

void main() {
  test('chapter progress is files done over total', () {
    expect(
      chapter('1', DownloadState.running, done: 1, total: 4).progress,
      0.25,
    );
    expect(chapter('1', DownloadState.queued).progress, 0);
  });

  test('a done chapter is complete even without files (text)', () {
    expect(chapter('1', DownloadState.done).progress, 1);
  });

  test('book aggregates counts, bytes and progress', () {
    final book = BookDownload(
      bookId: const BookId('b'),
      chapters: [
        chapter('1', DownloadState.done, done: 2, total: 2, bytes: 10),
        chapter('2', DownloadState.running, done: 0, total: 2, bytes: 5),
        chapter('3', DownloadState.failed, bytes: 1),
      ],
    );
    expect(book.count(DownloadState.done), 1);
    expect(book.count(DownloadState.failed), 1);
    expect(book.bytes, 16);
    expect(book.progress, closeTo(1 / 3, 1e-9));
  });
}
