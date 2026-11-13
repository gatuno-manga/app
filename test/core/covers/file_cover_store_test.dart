import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/covers/file_cover_store.dart';
import 'package:gatuno/core/database/offline_cache_database.dart';

void main() {
  late OfflineCacheDatabase db;
  late Directory dir;
  late Map<String, Uint8List?> remote;
  late List<String> downloads;
  late DateTime now;

  FileCoverStore build({int budgetBytes = 1000}) => FileCoverStore(
    db: db,
    directory: () async => Directory('${dir.path}/covers'),
    download: (url) async {
      downloads.add(url);
      return remote[url];
    },
    budgetBytes: budgetBytes,
    now: () => now,
  );

  Uint8List bytes(int length, [int fill = 1]) =>
      Uint8List.fromList(List.filled(length, fill));

  setUp(() {
    db = OfflineCacheDatabase(NativeDatabase.memory());
    dir = Directory.systemTemp.createTempSync('gatuno-covers');
    remote = {};
    downloads = [];
    now = DateTime(2026, 11, 13);
  });

  tearDown(() async {
    await db.close();
    dir.deleteSync(recursive: true);
  });

  test('ensure downloads once, then serves the file', () async {
    final store = build();
    remote['https://s3/1.webp'] = bytes(10);

    final first = await store.ensure('1', 'https://s3/1.webp');
    final second = await store.ensure('1', 'https://s3/1.webp');

    expect(first!.path, endsWith('/covers/1.webp'));
    expect(await second!.readAsBytes(), bytes(10));
    expect(downloads, ['https://s3/1.webp']);
    expect((await store.file('1'))!.path, first.path);
  });

  test('a changed cover URL replaces the file', () async {
    final store = build();
    remote['https://s3/1.webp'] = bytes(10, 1);
    remote['https://s3/1-new.jpg'] = bytes(10, 2);

    final old = await store.ensure('1', 'https://s3/1.webp');
    final fresh = await store.ensure('1', 'https://s3/1-new.jpg');

    expect(await fresh!.readAsBytes(), bytes(10, 2));
    expect(await old!.exists(), isFalse);
  });

  test('a failed download keeps the older cover, or returns null', () async {
    final store = build();
    remote['https://s3/1.webp'] = bytes(10);
    await store.ensure('1', 'https://s3/1.webp');

    final fallback = await store.ensure('1', 'https://s3/1-new.webp');
    expect(await fallback!.readAsBytes(), bytes(10));
    expect(await store.ensure('2', 'https://s3/2.webp'), isNull);
  });

  test('concurrent ensures share one download', () async {
    final store = build();
    remote['https://s3/1.webp'] = bytes(10);

    await Future.wait([
      store.ensure('1', 'https://s3/1.webp'),
      store.ensure('1', 'https://s3/1.webp'),
    ]);

    expect(downloads, hasLength(1));
  });

  test('a file deleted behind the store counts as missing', () async {
    final store = build();
    remote['https://s3/1.webp'] = bytes(10);
    final file = await store.ensure('1', 'https://s3/1.webp');
    await file!.delete();

    expect(await store.file('1'), isNull);
  });

  test('bookIdForUrl finds the cached book with that cover', () async {
    final store = build();
    await db
        .into(db.cachedBooks)
        .insert(
          CachedBooksCompanion.insert(
            id: 'b1',
            title: 'T',
            cover: const Value('https://s3/1.webp'),
            cachedAt: now,
            lastAccessedAt: now,
          ),
        );

    expect(await store.bookIdForUrl('https://s3/1.webp'), 'b1');
    expect(await store.bookIdForUrl('https://s3/other.webp'), isNull);
  });

  group('budget', () {
    test('evicts unpinned covers least recently used first', () async {
      final store = build(budgetBytes: 25);
      for (final id in ['1', '2', '3']) {
        remote['https://s3/$id.webp'] = bytes(10);
      }
      await store.ensure('1', 'https://s3/1.webp');
      now = now.add(const Duration(minutes: 1));
      await store.ensure('2', 'https://s3/2.webp');
      now = now.add(const Duration(minutes: 1));
      await store.file('1'); // 1 is now more recent than 2
      now = now.add(const Duration(minutes: 1));
      await store.ensure('3', 'https://s3/3.webp');
      await store.enforceBudget();

      expect(await store.file('1'), isNotNull);
      expect(await store.file('2'), isNull);
      expect(await store.file('3'), isNotNull);
    });

    test('pinned covers are exempt and do not count', () async {
      final store = build(budgetBytes: 10);
      remote['https://s3/1.webp'] = bytes(10);
      remote['https://s3/2.webp'] = bytes(10);
      await store.ensure('1', 'https://s3/1.webp');
      await store.pin('1', 'download');
      await store.ensure('2', 'https://s3/2.webp');
      await store.enforceBudget();

      expect(await store.file('1'), isNotNull);
      expect(await store.file('2'), isNotNull);

      await store.unpin('1', 'download');
      await store.enforceBudget();
      expect(await store.file('1'), isNull);
    });
  });

  test('remove and clear delete files and rows', () async {
    final store = build();
    remote['https://s3/1.webp'] = bytes(10);
    remote['https://s3/2.webp'] = bytes(10);
    final one = await store.ensure('1', 'https://s3/1.webp');
    await store.ensure('2', 'https://s3/2.webp');
    await store.pin('2', 'download');

    await store.remove(['1']);
    expect(await one!.exists(), isFalse);
    expect(await store.file('1'), isNull);

    await store.clear();
    expect(await store.file('2'), isNull);
    expect(await db.select(db.coverPins).get(), isEmpty);
    expect(Directory('${dir.path}/covers').existsSync(), isFalse);
  });
}
