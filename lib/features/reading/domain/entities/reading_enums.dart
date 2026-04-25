import 'package:gatuno/core/exceptions/mapping_exception.dart';

enum ContentType {
  image('image'),
  text('text'),
  document('document');

  final String value;
  const ContentType(this.value);

  static ContentType fromString(String value) {
    return ContentType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw MappingException('Unknown ContentType: $value'),
    );
  }
}

enum DocumentFormat {
  pdf('pdf'),
  epub('epub');

  final String value;
  const DocumentFormat(this.value);

  static DocumentFormat fromString(String value) {
    return DocumentFormat.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw MappingException('Unknown DocumentFormat: $value'),
    );
  }
}

enum ContentFormat {
  markdown('markdown'),
  html('html'),
  plain('plain');

  final String value;
  const ContentFormat(this.value);

  static ContentFormat fromString(String value) {
    return ContentFormat.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw MappingException('Unknown ContentFormat: $value'),
    );
  }
}

enum BookType {
  manga('manga'),
  manhwa('manhwa'),
  manhua('manhua'),
  book('book'),
  other('other');

  final String value;
  const BookType(this.value);

  static BookType fromString(String value) {
    return BookType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw MappingException('Unknown BookType: $value'),
    );
  }
}
