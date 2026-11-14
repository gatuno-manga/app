import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/downloads/domain/use_cases/chapter_file_plan.dart';
import 'package:gatuno/features/downloads/exceptions/download_exceptions.dart';
import 'package:gatuno/features/reading/data/models/reading_chapter_model.dart';

ReadingChapterModel chapter(Map<String, dynamic> overrides) =>
    ReadingChapterModel.fromJson({
      'id': 'c1',
      'originalUrl': 'https://origin/c1',
      'index': 1,
      'contentType': 'image',
      'retries': 0,
      'bookId': 'b1',
      'bookTitle': 'Book',
      'totalChapters': 1,
      'pages': <dynamic>[],
      'comments': <dynamic>[],
      ...overrides,
    });

void main() {
  test('image pages follow the page index, numbered from 0001', () {
    final files = ChapterFilePlan.of(
      chapter({
        'pages': [
          {'id': 'b', 'path': '/s3/b.PNG', 'index': 2},
          {'id': 'a', 'path': '/s3/a.jpg?v=1', 'index': 1},
          {'id': 'c', 'path': '/s3/noext', 'index': 3},
        ],
      }),
    );

    expect(files.map((f) => (f.position, f.url, f.relativePath)), [
      (1, '/s3/a.jpg?v=1', 'pages/0001.jpg'),
      (2, '/s3/b.PNG', 'pages/0002.png'),
      (3, '/s3/noext', 'pages/0003.img'),
    ]);
  });

  test('a document is one file named after its format', () {
    final files = ChapterFilePlan.of(
      chapter({
        'contentType': 'document',
        'documentPath': '/s3/book.bin',
        'documentFormat': 'epub',
      }),
    );

    expect(files.single.relativePath, 'document.epub');
    expect(files.single.directory, isEmpty);
    expect(files.single.position, 0);
  });

  test('a text chapter has no files', () {
    expect(
      ChapterFilePlan.of(chapter({'contentType': 'text', 'content': 'Hi'})),
      isEmpty,
    );
  });

  test('a chapter with nothing to download yet is unavailable', () {
    expect(
      () => ChapterFilePlan.of(chapter({})),
      throwsA(isA<ChapterUnavailableException>()),
    );
    expect(
      () => ChapterFilePlan.of(chapter({'contentType': 'document'})),
      throwsA(isA<ChapterUnavailableException>()),
    );
    expect(
      () => ChapterFilePlan.of(chapter({'contentType': 'text'})),
      throwsA(isA<ChapterUnavailableException>()),
    );
  });
}
