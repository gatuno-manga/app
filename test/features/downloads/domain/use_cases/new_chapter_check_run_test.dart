import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/downloads/domain/entities/book_download.dart';
import 'package:gatuno/features/downloads/domain/entities/chapter_download.dart';
import 'package:gatuno/features/downloads/domain/entities/download_state.dart';
import 'package:gatuno/features/downloads/domain/repositories/download_service.dart';
import 'package:gatuno/features/downloads/domain/use_cases/new_chapter_check.dart';
import 'package:gatuno/features/downloads/domain/use_cases/new_chapter_check_run.dart';
import 'package:mocktail/mocktail.dart';

class MockCheck extends Mock implements NewChapterCheck {}

class MockDownloadService extends Mock implements DownloadService {}

void main() {
  const book = BookId('book-1');
  late MockCheck check;
  late MockDownloadService downloads;
  late NewChapterCheckRun run;

  setUp(() {
    check = MockCheck();
    downloads = MockDownloadService();
    run = NewChapterCheckRun(check, downloads);
  });

  DateTime inAMinute() => DateTime.now().add(const Duration(minutes: 1));

  test('waits until the queued chapters are planned', () async {
    when(
      () => check.run(
        deadline: any(named: 'deadline'),
        stopRequested: any(named: 'stopRequested'),
      ),
    ).thenAnswer(
      (_) async => NewChapterCheckResult(
        NewChapterCheckOutcome.done,
        queued: {
          book: const [ChapterId('c1')],
        },
      ),
    );
    when(() => downloads.watchBook(book)).thenAnswer(
      (_) => Stream.value(
        const BookDownload(
          bookId: book,
          chapters: [
            ChapterDownload(
              chapterId: ChapterId('c1'),
              bookId: book,
              state: DownloadState.queued,
              filesTotal: 3,
            ),
          ],
        ),
      ),
    );

    await run.run(deadline: inAMinute());

    verify(() => downloads.watchBook(book)).called(1);
  });

  test('passes the stop request to the check', () async {
    final stop = Completer<void>();
    bool Function()? stopRequested;
    when(
      () => check.run(
        deadline: any(named: 'deadline'),
        stopRequested: any(named: 'stopRequested'),
      ),
    ).thenAnswer((invocation) async {
      stopRequested =
          invocation.namedArguments[#stopRequested] as bool Function();
      return const NewChapterCheckResult(NewChapterCheckOutcome.done);
    });

    await run.run(deadline: inAMinute(), stopped: stop.future);
    expect(stopRequested!(), isFalse);
    stop.complete();
    await pumpEventQueue();
    expect(stopRequested!(), isTrue);
  });

  test('a check that never answers is cut at the deadline', () async {
    when(
      () => check.run(
        deadline: any(named: 'deadline'),
        stopRequested: any(named: 'stopRequested'),
      ),
    ).thenAnswer((_) => Completer<NewChapterCheckResult>().future);

    await run.run(
      deadline: DateTime.now().add(const Duration(milliseconds: 50)),
    );
  });
}
