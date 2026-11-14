import '../../../books/domain/entities/book_type.dart';
import '../../../reading/domain/entities/reading_enums.dart';

/// The books feature's [TypeBook] as the [BookType] network rules use.
extension DownloadBookType on TypeBook? {
  BookType get asBookType => switch (this) {
    TypeBook.manga => BookType.manga,
    TypeBook.manhwa => BookType.manhwa,
    TypeBook.manhua => BookType.manhua,
    TypeBook.book => BookType.book,
    TypeBook.other || null => BookType.other,
  };
}
