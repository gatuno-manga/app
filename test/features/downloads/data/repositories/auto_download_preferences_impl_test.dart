import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/downloads/data/data_sources/download_records.dart';
import 'package:gatuno/features/downloads/data/database/downloads_database.dart';
import 'package:gatuno/features/downloads/data/repositories/auto_download_preferences_impl.dart';
import 'package:gatuno/features/downloads/domain/entities/auto_download.dart';
import 'package:gatuno/features/reading/domain/entities/reading_enums.dart';

void main() {
  const book = BookId('book-1');
  late DownloadsDatabase db;
  late DownloadRecords records;
  late DateTime now;
  late AutoDownloadPreferencesImpl prefs;

  setUp(() {
    db = DownloadsDatabase(NativeDatabase.memory());
    records = DownloadRecords(db);
    now = DateTime(2026, 11, 15, 10);
    prefs = AutoDownloadPreferencesImpl(records, now: () => now);
  });

  tearDown(() => db.close());

  test('is off for a book never set', () async {
    expect(await prefs.watch(book).first, isNull);
    expect(await prefs.enabledBooks(), isEmpty);
  });

  test('enable records the book with since set to now', () async {
    await prefs.enable(book);

    final expected = AutoDownload(bookId: book, since: now);
    expect(await prefs.watch(book).first, expected);
    expect(await prefs.enabledBooks(), [expected]);
    expect(await records.bookIds(), ['book-1']);
  });

  test('enable again moves since forward', () async {
    await prefs.enable(book);
    now = DateTime(2026, 11, 16);

    await prefs.enable(book);

    expect((await prefs.watch(book).first)!.since, DateTime(2026, 11, 16));
  });

  test('enable keeps the type and order of a book with downloads', () async {
    await records.upsertBook('book-1', BookType.manga, DateTime(2026));
    await records.insertChapter('c1', 'book-1', DateTime(2026));

    await prefs.enable(book);

    expect(await records.bookType('book-1'), BookType.manga);
    expect((await prefs.watch(book).first)!.since, now);
  });

  test('disable drops a row that has no chapter', () async {
    await prefs.enable(book);

    await prefs.disable(book);

    expect(await prefs.watch(book).first, isNull);
    expect(await records.bookIds(), isEmpty);
  });

  test('disable keeps a row that has chapters', () async {
    await records.upsertBook('book-1', BookType.manga, DateTime(2026));
    await records.insertChapter('c1', 'book-1', DateTime(2026));
    await prefs.enable(book);

    await prefs.disable(book);

    expect(await prefs.watch(book).first, isNull);
    expect(await records.bookIds(), ['book-1']);
  });

  test('disable of a book never set does nothing', () async {
    await prefs.disable(book);

    expect(await records.bookIds(), isEmpty);
  });

  test('watch emits every change', () async {
    final emitted = <AutoDownload?>[];
    final sub = prefs.watch(book).listen(emitted.add);
    await pumpEventQueue();

    await prefs.enable(book);
    await pumpEventQueue();
    await prefs.disable(book);
    await pumpEventQueue();
    await sub.cancel();

    expect(emitted, [null, AutoDownload(bookId: book, since: now), null]);
  });

  test('enabledBooks lists only books with it on, oldest first', () async {
    await prefs.enable(const BookId('b2'));
    now = DateTime(2026, 11, 14);
    await prefs.enable(const BookId('b1'));
    await records.upsertBook('b3', BookType.manga, DateTime(2026));

    expect(await prefs.enabledBooks(), [
      AutoDownload(bookId: const BookId('b1'), since: DateTime(2026, 11, 14)),
      AutoDownload(
        bookId: const BookId('b2'),
        since: DateTime(2026, 11, 15, 10),
      ),
    ]);
  });

  group('deleteBookIfEmpty', () {
    test('keeps a flagged row and reports the book empty', () async {
      await records.upsertBook('book-1', BookType.manga, DateTime(2026));
      await prefs.enable(book);

      expect(await records.deleteBookIfEmpty('book-1'), isTrue);
      expect(await records.bookIds(), ['book-1']);
      expect(await prefs.watch(book).first, isNotNull);
    });

    test('drops an unflagged empty row', () async {
      await records.upsertBook('book-1', BookType.manga, DateTime(2026));

      expect(await records.deleteBookIfEmpty('book-1'), isTrue);
      expect(await records.bookIds(), isEmpty);
    });

    test('leaves a book with chapters alone', () async {
      await records.upsertBook('book-1', BookType.manga, DateTime(2026));
      await records.insertChapter('c1', 'book-1', DateTime(2026));

      expect(await records.deleteBookIfEmpty('book-1'), isFalse);
      expect(await records.bookIds(), ['book-1']);
    });
  });

  test('clearing the downloads clears the setting', () async {
    await prefs.enable(book);

    await records.clear();

    expect(await prefs.enabledBooks(), isEmpty);
    expect(await prefs.watch(book).first, isNull);
  });
}
