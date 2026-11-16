import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/downloads/domain/use_cases/checking_auto_download_preferences.dart';
import 'package:gatuno/features/downloads/domain/entities/auto_download.dart';
import 'package:gatuno/features/downloads/domain/repositories/auto_download_preferences.dart';
import 'package:gatuno/features/downloads/domain/repositories/new_chapter_check_scheduler.dart';
import 'package:gatuno/features/downloads/domain/use_cases/new_chapter_check.dart';
import 'package:mocktail/mocktail.dart';

class MockPreferences extends Mock implements AutoDownloadPreferences {}

class MockCheck extends Mock implements NewChapterCheck {}

class MockScheduler extends Mock implements NewChapterCheckScheduler {}

void main() {
  const book = BookId('book-1');
  late MockPreferences inner;
  late MockCheck check;
  late MockScheduler scheduler;
  late CheckingAutoDownloadPreferences prefs;

  setUpAll(() => registerFallbackValue(Duration.zero));

  setUp(() {
    inner = MockPreferences();
    check = MockCheck();
    scheduler = MockScheduler();
    when(() => inner.enable(book)).thenAnswer((_) async {});
    when(() => inner.disable(book)).thenAnswer((_) async {});
    when(() => check.run(only: any(named: 'only'))).thenAnswer(
      (_) async => const NewChapterCheckResult(NewChapterCheckOutcome.done),
    );
    when(() => scheduler.schedule(any())).thenAnswer((_) async {});
    when(() => scheduler.cancel()).thenAnswer((_) async {});
    prefs = CheckingAutoDownloadPreferences(inner, check, scheduler);
  });

  test('turning it on checks that book and schedules the check', () async {
    await prefs.enable(book);
    await pumpEventQueue();

    verifyInOrder([() => inner.enable(book), () => check.run(only: book)]);
    verify(
      () => scheduler.schedule(CheckingAutoDownloadPreferences.interval),
    ).called(1);
  });

  test('turning the last one off cancels the schedule', () async {
    when(() => inner.enabledBooks()).thenAnswer((_) async => []);

    await prefs.disable(book);
    await pumpEventQueue();

    verify(() => inner.disable(book)).called(1);
    verify(() => scheduler.cancel()).called(1);
  });

  test('turning one off keeps the schedule while others are on', () async {
    when(() => inner.enabledBooks()).thenAnswer(
      (_) async => [
        AutoDownload(bookId: const BookId('b2'), since: DateTime(2026)),
      ],
    );

    await prefs.disable(book);
    await pumpEventQueue();

    verifyNever(() => scheduler.cancel());
    verify(() => scheduler.schedule(any())).called(1);
  });

  test('a scheduler failure does not fail the setting', () async {
    when(() => scheduler.schedule(any())).thenThrow(Exception('no plugin'));

    await prefs.enable(book);
    await pumpEventQueue();

    verify(() => inner.enable(book)).called(1);
  });
}
