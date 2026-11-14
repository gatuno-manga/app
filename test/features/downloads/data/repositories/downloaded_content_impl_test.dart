import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/downloads/data/data_sources/download_storage.dart';
import 'package:gatuno/features/downloads/data/database/downloads_database.dart';
import 'package:gatuno/features/downloads/data/repositories/downloaded_content_impl.dart';
import 'package:gatuno/features/downloads/domain/entities/download_state.dart';
import 'package:gatuno/features/reading/domain/entities/reading_enums.dart';

void main() {
  late DownloadsDatabase db;
  late Directory dir;
  late DownloadStorage storage;
  late DownloadedContentImpl content;

  Map<String, dynamic> manifest(String type) => {
    'id': 'c1',
    'title': 'One',
    'originalUrl': 'https://origin/c1',
    'index': 1,
    'contentType': type,
    'content': type == 'text' ? 'Hello' : null,
    'contentFormat': type == 'text' ? 'plain' : null,
    'documentFormat': type == 'document' ? 'pdf' : null,
    'retries': 0,
    'isFinal': false,
    'next': 'c2',
    'bookId': 'b1',
    'bookTitle': 'Book',
    'totalChapters': 2,
    'pages': type == 'image'
        ? [
            {'id': 'p1', 'path': '/s3/1.jpg', 'index': 1},
            {'id': 'p2', 'path': '/s3/2.jpg', 'index': 2},
          ]
        : <dynamic>[],
    'comments': <dynamic>[],
  };

  Future<void> store(
    String type, {
    DownloadState state = DownloadState.done,
    List<String> files = const [],
  }) async {
    await db
        .into(db.downloadChapters)
        .insert(
          DownloadChaptersCompanion.insert(
            chapterId: 'c1',
            bookId: 'b1',
            state: state,
            enqueuedAt: DateTime(2026),
          ),
        );
    await storage.writeManifest('b1', 'c1', manifest(type));
    for (final (i, path) in files.indexed) {
      await db
          .into(db.downloadFiles)
          .insert(
            DownloadFilesCompanion.insert(
              fileId: 'c1/$i',
              chapterId: 'c1',
              position: i,
              url: 'https://srv/$path',
              relativePath: path,
            ),
          );
      final file = await storage.file('b1', 'c1', path);
      await file.parent.create(recursive: true);
      await file.writeAsBytes([i]);
    }
  }

  setUp(() {
    db = DownloadsDatabase(NativeDatabase.memory());
    dir = Directory.systemTemp.createTempSync('gatuno-downloaded');
    storage = DownloadStorage(() async => dir);
    content = DownloadedContentImpl(db, storage);
  });

  tearDown(() async {
    await db.close();
    dir.deleteSync(recursive: true);
  });

  test('an image chapter gives its manifest and pages in order', () async {
    await store('image', files: ['pages/0001.jpg', 'pages/0002.jpg']);

    final downloaded = await content.chapter(const ChapterId('c1'));

    expect(downloaded!.chapter.id, const ChapterId('c1'));
    expect(downloaded.chapter.next, const ChapterId('c2'));
    expect(downloaded.chapter.pages, hasLength(2));
    expect(downloaded.pages.map((f) => f.path.split('/').last), [
      '0001.jpg',
      '0002.jpg',
    ]);
    expect(downloaded.document, isNull);
  });

  test('a text chapter gives its inline content', () async {
    await store('text');

    final downloaded = await content.chapter(const ChapterId('c1'));

    expect(downloaded!.chapter.contentType, ContentType.text);
    expect(downloaded.chapter.content!.value, 'Hello');
    expect(downloaded.pages, isEmpty);
  });

  test('a document chapter gives its file', () async {
    await store('document', files: ['document.pdf']);

    final downloaded = await content.chapter(const ChapterId('c1'));

    expect(downloaded!.document!.path, endsWith('/b1/c1/document.pdf'));
  });

  test('nothing until the chapter is done', () async {
    await store('text', state: DownloadState.running);

    expect(await content.chapter(const ChapterId('c1')), isNull);
    expect(await content.chapter(const ChapterId('other')), isNull);
  });

  test('nothing when a file was deleted behind the app', () async {
    await store('image', files: ['pages/0001.jpg', 'pages/0002.jpg']);
    (await storage.file('b1', 'c1', 'pages/0002.jpg')).deleteSync();

    expect(await content.chapter(const ChapterId('c1')), isNull);
  });
}
