import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_index.dart';
import 'package:gatuno/features/downloads/domain/repositories/downloaded_content.dart';
import 'package:gatuno/features/reading/domain/entities/reading_chapter.dart';
import 'package:gatuno/features/reading/domain/entities/reading_enums.dart';
import 'package:gatuno/features/reading/domain/use_cases/document_source.dart';
import 'package:gatuno/features/reading/domain/value_objects/document_path.dart';
import 'package:gatuno/features/reading/domain/value_objects/original_url.dart';
import 'package:gatuno/shared/domain/value_objects/positive_int.dart';
import 'package:mocktail/mocktail.dart';

class MockDownloadedContent extends Mock implements DownloadedContent {}

ReadingChapter _chapter({
  ContentType type = ContentType.document,
  String? documentPath = '/s3/book/c1.pdf',
}) => ReadingChapter(
  id: const ChapterId('c1'),
  originalUrl: const OriginalUrl('https://origin/c1'),
  index: const ChapterIndex(1),
  contentType: type,
  documentPath: documentPath == null ? null : DocumentPath(documentPath),
  documentFormat: DocumentFormat.pdf,
  retries: const PositiveInt(0),
  isFinal: false,
  bookId: const BookId('b1'),
  bookTitle: const BookTitle('Book'),
  totalChapters: const PositiveInt(1),
  pages: const [],
  comments: const [],
);

void main() {
  late MockDownloadedContent downloads;
  late DocumentSource source;

  setUp(() {
    downloads = MockDownloadedContent();
    source = DocumentSource(downloads);
  });

  test('a downloaded document resolves to its file', () async {
    final file = File('/downloads/b1/c1/document.pdf');
    when(
      () => downloads.localFile('/s3/book/c1.pdf'),
    ).thenAnswer((_) async => file);

    expect(await source.resolve(_chapter()), same(file));
  });

  test('a document that is not downloaded reads from the server', () async {
    when(() => downloads.localFile(any())).thenAnswer((_) async => null);

    expect(await source.resolve(_chapter()), isNull);
  });

  test('a failed lookup reads from the server', () async {
    when(() => downloads.localFile(any())).thenThrow(StateError('db closed'));

    expect(await source.resolve(_chapter()), isNull);
  });

  test('no lookup without a document', () async {
    expect(await source.resolve(_chapter(type: ContentType.image)), isNull);
    expect(await source.resolve(_chapter(documentPath: null)), isNull);
    verifyNever(() => downloads.localFile(any()));
  });
}
