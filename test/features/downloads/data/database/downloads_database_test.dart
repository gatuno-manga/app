import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/downloads/data/database/downloads_database.dart';

void main() {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('gatuno-downloads-db');
    file = File('${dir.path}/downloads.sqlite');
  });

  tearDown(() => dir.deleteSync(recursive: true));

  Future<bool> hasUrlIndex(DownloadsDatabase db) async {
    final rows = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND name = 'idx_download_files_url'",
        )
        .get();
    return rows.isNotEmpty;
  }

  test('a new database has the file URL index', () async {
    final db = DownloadsDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(await hasUrlIndex(db), isTrue);
  });

  test('upgrading from version 1 adds the file URL index', () async {
    // A version 1 database: today's schema without the index and without
    // version 3's auto-download column.
    final v1 = DownloadsDatabase(NativeDatabase(file));
    await v1.customStatement('DROP INDEX idx_download_files_url');
    await v1.customStatement(
      'ALTER TABLE download_books DROP COLUMN auto_download_since',
    );
    await v1.customStatement('PRAGMA user_version = 1');
    await v1
        .into(v1.downloadFiles)
        .insert(
          DownloadFilesCompanion.insert(
            fileId: 'c1/1',
            chapterId: 'c1',
            position: 1,
            url: 'https://srv/s3/1.jpg',
            relativePath: 'pages/0001.jpg',
          ),
        );
    await v1.close();

    final db = DownloadsDatabase(NativeDatabase(file));
    addTearDown(db.close);

    expect(await hasUrlIndex(db), isTrue);
    expect(await db.select(db.downloadFiles).get(), hasLength(1));
    expect(db.schemaVersion, 3);
  });

  test('the index serves lookups by URL', () async {
    final db = DownloadsDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final plan = await db
        .customSelect(
          'EXPLAIN QUERY PLAN SELECT * FROM download_files WHERE url = ?',
          variables: [Variable.withString('x')],
        )
        .get();

    expect(
      plan.map((r) => r.read<String>('detail')).join(' '),
      contains('idx_download_files_url'),
    );
  });
}
