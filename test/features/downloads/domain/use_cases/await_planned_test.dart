import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/downloads/domain/entities/book_download.dart';
import 'package:gatuno/features/downloads/domain/entities/chapter_download.dart';
import 'package:gatuno/features/downloads/domain/entities/download_state.dart';
import 'package:gatuno/features/downloads/domain/repositories/download_service.dart';
import 'package:gatuno/features/downloads/domain/use_cases/await_planned.dart';
import 'package:mocktail/mocktail.dart';

class MockDownloadService extends Mock implements DownloadService {}

void main() {
  const book = BookId('book-1');
  late MockDownloadService downloads;
  late StreamController<BookDownload?> updates;

  setUp(() {
    downloads = MockDownloadService();
    updates = StreamController<BookDownload?>();
    when(() => downloads.watchBook(book)).thenAnswer((_) => updates.stream);
  });

  tearDown(() => updates.close());

  BookDownload withChapter(DownloadState state, {int files = 0}) =>
      BookDownload(
        bookId: book,
        chapters: [
          ChapterDownload(
            chapterId: const ChapterId('c1'),
            bookId: book,
            state: state,
            filesTotal: files,
          ),
        ],
      );

  test('returns once the queued chapter has its files planned', () async {
    var finished = false;
    final wait = awaitPlanned(
      downloads,
      {
        book: [const ChapterId('c1')],
      },
      deadline: DateTime.now().add(const Duration(minutes: 1)),
    ).then((_) => finished = true);

    updates.add(withChapter(DownloadState.queued));
    await pumpEventQueue();
    expect(finished, isFalse);

    updates.add(withChapter(DownloadState.queued, files: 12));
    await wait;
    expect(finished, isTrue);
  });

  test('a done or failed chapter counts as planned', () async {
    final wait = awaitPlanned(downloads, {
      book: [const ChapterId('c1')],
    }, deadline: DateTime.now().add(const Duration(minutes: 1)));
    updates.add(withChapter(DownloadState.failed));
    await wait;
  });

  test('gives up at the deadline', () async {
    await awaitPlanned(downloads, {
      book: [const ChapterId('c1')],
    }, deadline: DateTime.now().add(const Duration(milliseconds: 20)));
  });
}
