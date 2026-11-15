import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/downloads/data/data_sources/download_records.dart';
import 'package:gatuno/features/downloads/data/database/downloads_database.dart';
import 'package:gatuno/features/reading/domain/entities/reading_enums.dart';

void main() {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('gatuno-downloads-db');
    file = File('${dir.path}/downloads.sqlite');
  });

  tearDown(() => dir.deleteSync(recursive: true));

  /// Writes a database at [version] holding one book: today's schema without
  /// the steps after it.
  Future<void> writeOld(int version) async {
    final old = DownloadsDatabase(NativeDatabase(file));
    await old.customStatement(
      'ALTER TABLE download_books DROP COLUMN auto_download_since',
    );
    if (version < 2) {
      await old.customStatement('DROP INDEX idx_download_files_url');
    }
    await old.customStatement('PRAGMA user_version = $version');
    await old
        .into(old.downloadBooks)
        .insert(
          DownloadBooksCompanion.insert(
            bookId: 'book-1',
            bookType: BookType.manga,
            enqueuedAt: DateTime(2026),
          ),
        );
    await old.close();
  }

  Future<int> userVersion(DownloadsDatabase db) => db
      .customSelect('PRAGMA user_version')
      .map((r) => r.read<int>('user_version'))
      .getSingle();

  for (final from in [1, 2]) {
    test('version $from gains autoDownloadSince and keeps its books', () async {
      await writeOld(from);

      final db = DownloadsDatabase(NativeDatabase(file));
      addTearDown(db.close);

      final row = await db.select(db.downloadBooks).getSingle();
      expect(row.bookId, 'book-1');
      expect(row.bookType, BookType.manga);
      expect(row.autoDownloadSince, isNull);
      expect(await userVersion(db), 3);

      final since = DateTime(2026, 11, 15);
      await DownloadRecords(db).enableAutoDownload('book-1', since);
      expect(
        (await db.select(db.downloadBooks).getSingle()).autoDownloadSince,
        since,
      );
    });
  }

  test('a new database starts at version 3', () async {
    final db = DownloadsDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.select(db.downloadBooks).get();

    expect(db.schemaVersion, 3);
    expect(await userVersion(db), 3);
  });
}
