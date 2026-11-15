import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/downloads/data/data_sources/download_records.dart';
import 'package:gatuno/features/downloads/data/database/downloads_database.dart';
import 'package:gatuno/features/downloads/data/repositories/records_new_chapter_ledger.dart';
import 'package:gatuno/features/downloads/domain/entities/auto_download_check_state.dart';

void main() {
  const bookA = BookId('book-a');
  const bookB = BookId('book-b');
  late DownloadsDatabase db;
  late DownloadRecords records;
  late RecordsNewChapterLedger ledger;
  final since = DateTime(2026, 11, 15, 10);
  final at = DateTime(2026, 11, 15, 11);

  setUp(() {
    db = DownloadsDatabase(NativeDatabase.memory());
    records = DownloadRecords(db);
    ledger = RecordsNewChapterLedger(records);
  });

  tearDown(() => db.close());

  Future<AutoDownloadCheckState> only() async => (await ledger.books()).single;

  test('a book just turned on has no baseline and was never checked', () async {
    await records.enableAutoDownload('book-a', since);

    expect(
      await only(),
      AutoDownloadCheckState(bookId: bookA, since: since, hasBaseline: false),
    );
    expect(await ledger.lastCheck(), isNull);
  });

  test('a baseline replaces the seen set and marks the check', () async {
    await records.enableAutoDownload('book-a', since);
    final book = await only();

    expect(
      await ledger.record(
        book,
        chapters: {const ChapterId('c1'), const ChapterId('c2')},
        baseline: true,
        at: at,
      ),
      isTrue,
    );

    final checked = await only();
    expect(checked.hasBaseline, isTrue);
    expect(checked.checkedAt, at);
    expect(await ledger.seen(bookA), {
      const ChapterId('c1'),
      const ChapterId('c2'),
    });
    expect(await ledger.lastCheck(), at);
  });

  test('later checks add to the seen set', () async {
    await records.enableAutoDownload('book-a', since);
    await ledger.record(
      await only(),
      chapters: {const ChapterId('c1')},
      baseline: true,
      at: at,
    );

    await ledger.record(
      await only(),
      chapters: {const ChapterId('c1'), const ChapterId('c2')},
      baseline: false,
      at: at.add(const Duration(hours: 6)),
    );

    expect(await ledger.seen(bookA), {
      const ChapterId('c1'),
      const ChapterId('c2'),
    });
  });

  test('turning it on again asks for a new baseline', () async {
    await records.enableAutoDownload('book-a', since);
    await ledger.record(
      await only(),
      chapters: {const ChapterId('c1')},
      baseline: true,
      at: at,
    );

    await records.enableAutoDownload('book-a', DateTime(2026, 11, 16));

    expect((await only()).hasBaseline, isFalse);
  });

  test('turning it off forgets the seen set', () async {
    await records.enableAutoDownload('book-a', since);
    await ledger.record(
      await only(),
      chapters: {const ChapterId('c1')},
      baseline: true,
      at: at,
    );
    await records.upsertBook('book-a', null, since);
    await records.insertChapter('c1', 'book-a', since);

    await records.disableAutoDownload('book-a');
    await records.enableAutoDownload('book-a', DateTime(2026, 11, 16));

    expect(await ledger.seen(bookA), isEmpty);
    expect((await only()).checkedAt, isNull);
  });

  test('writes nothing for a book turned off or on again meanwhile', () async {
    await records.enableAutoDownload('book-a', since);
    final stale = await only();
    await records.enableAutoDownload('book-a', DateTime(2026, 11, 16));

    expect(
      await ledger.record(
        stale,
        chapters: {const ChapterId('c1')},
        baseline: true,
        at: at,
      ),
      isFalse,
    );
    expect(await ledger.seen(bookA), isEmpty);

    await records.disableAutoDownload('book-a');
    expect(
      await ledger.record(
        stale,
        chapters: {const ChapterId('c1')},
        baseline: true,
        at: at,
      ),
      isFalse,
    );
  });

  test('never checked books come first, then the least recent', () async {
    await records.enableAutoDownload('book-a', since);
    await records.enableAutoDownload(
      'book-b',
      since.add(const Duration(hours: 1)),
    );
    await ledger.record(
      (await ledger.books()).first,
      chapters: const {},
      baseline: true,
      at: at,
    );

    expect([for (final b in await ledger.books()) b.bookId], [bookB, bookA]);
  });

  test('a server change wipes the setting and the seen sets', () async {
    await records.enableAutoDownload('book-a', since);
    await ledger.record(
      await only(),
      chapters: {const ChapterId('c1')},
      baseline: true,
      at: at,
    );

    await records.clear();

    expect(await ledger.books(), isEmpty);
    expect(await ledger.seen(bookA), isEmpty);
  });
}
