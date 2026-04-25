import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/exceptions/mapping_exception.dart';
import 'package:gatuno/features/reading/domain/entities/reading_enums.dart';

void main() {
  group('ReadingEnums', () {
    group('ContentType', () {
      test('fromString returns correct enum', () {
        expect(ContentType.fromString('image'), ContentType.image);
        expect(ContentType.fromString('text'), ContentType.text);
        expect(ContentType.fromString('document'), ContentType.document);
      });

      test('fromString throws MappingException for unknown value', () {
        expect(
          () => ContentType.fromString('unknown'),
          throwsA(isA<MappingException>()),
        );
      });
    });

    group('DocumentFormat', () {
      test('fromString returns correct enum', () {
        expect(DocumentFormat.fromString('pdf'), DocumentFormat.pdf);
        expect(DocumentFormat.fromString('epub'), DocumentFormat.epub);
      });

      test('fromString throws MappingException for unknown value', () {
        expect(
          () => DocumentFormat.fromString('unknown'),
          throwsA(isA<MappingException>()),
        );
      });
    });

    group('ContentFormat', () {
      test('fromString returns correct enum', () {
        expect(ContentFormat.fromString('markdown'), ContentFormat.markdown);
        expect(ContentFormat.fromString('html'), ContentFormat.html);
        expect(ContentFormat.fromString('plain'), ContentFormat.plain);
      });

      test('fromString throws MappingException for unknown value', () {
        expect(
          () => ContentFormat.fromString('unknown'),
          throwsA(isA<MappingException>()),
        );
      });
    });

    group('BookType', () {
      test('fromString returns correct enum', () {
        expect(BookType.fromString('manga'), BookType.manga);
        expect(BookType.fromString('manhwa'), BookType.manhwa);
        expect(BookType.fromString('manhua'), BookType.manhua);
        expect(BookType.fromString('book'), BookType.book);
        expect(BookType.fromString('other'), BookType.other);
      });

      test('fromString throws MappingException for unknown value', () {
        expect(
          () => BookType.fromString('unknown'),
          throwsA(isA<MappingException>()),
        );
      });
    });
  });
}
