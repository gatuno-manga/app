import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/downloads/data/data_sources/download_storage.dart';

void main() {
  late Directory dir;
  late DownloadStorage storage;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('gatuno-storage');
    storage = DownloadStorage(() async => dir);
  });

  tearDown(() => dir.deleteSync(recursive: true));

  test('lays chapters out under downloads/<book>/<chapter>', () async {
    final bytes = await storage.writeManifest('b1', 'c1', {'id': 'c1'});

    final manifest = File('${dir.path}/downloads/b1/c1/chapter.json');
    expect(manifest.existsSync(), isTrue);
    expect(bytes, manifest.lengthSync());
    expect(await storage.readManifest('b1', 'c1'), {'id': 'c1'});
    expect(DownloadStorage.chapterPath('b1', 'c1'), 'downloads/b1/c1');
  });

  test('ids cannot escape their directory', () {
    expect(DownloadStorage.chapterPath('../b', 'c/1'), 'downloads/___b/c_1');
  });

  test('sizeOf is null for a missing file', () async {
    expect(await storage.sizeOf('b1', 'c1', 'pages/0001.jpg'), isNull);
    final file = await storage.file('b1', 'c1', 'pages/0001.jpg');
    await file.parent.create(recursive: true);
    await file.writeAsBytes([1, 2]);
    expect(await storage.sizeOf('b1', 'c1', 'pages/0001.jpg'), 2);
  });

  test('a missing or corrupt manifest reads as null', () async {
    expect(await storage.readManifest('b1', 'c1'), isNull);
    final file = await storage.file('b1', 'c1', DownloadStorage.manifestName);
    await file.parent.create(recursive: true);
    await file.writeAsString('{not json');
    expect(await storage.readManifest('b1', 'c1'), isNull);
  });

  test('deletes a chapter, a book, everything', () async {
    await storage.writeManifest('b1', 'c1', {});
    await storage.writeManifest('b1', 'c2', {});
    await storage.writeManifest('b2', 'c3', {});

    await storage.deleteChapter('b1', 'c1');
    expect(Directory('${dir.path}/downloads/b1/c1').existsSync(), isFalse);
    expect(Directory('${dir.path}/downloads/b1/c2').existsSync(), isTrue);

    await storage.deleteBook('b1');
    expect(Directory('${dir.path}/downloads/b1').existsSync(), isFalse);

    await storage.deleteAll();
    expect(Directory('${dir.path}/downloads').existsSync(), isFalse);
  });

  test('transferTarget splits a file into directory and name', () {
    expect(DownloadStorage.transferTarget('b1', 'c1', 'pages/0001.jpg'), (
      directory: 'downloads/b1/c1/pages',
      filename: '0001.jpg',
    ));
    expect(DownloadStorage.transferTarget('b1', 'c1', 'document.pdf'), (
      directory: 'downloads/b1/c1',
      filename: 'document.pdf',
    ));
  });
}
