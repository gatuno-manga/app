import 'package:gatuno/l10n/app_localizations.dart';

import '../domain/entities/book_type.dart';

/// Localized label of a book type; a missing type reads as "Unknown".
String bookTypeLabel(AppLocalizations l10n, TypeBook? type) {
  switch (type) {
    case TypeBook.manga:
      return l10n.bookTypeManga;
    case TypeBook.manhwa:
      return l10n.bookTypeManhwa;
    case TypeBook.manhua:
      return l10n.bookTypeManhua;
    case TypeBook.book:
      return l10n.bookTypeBook;
    case TypeBook.other:
      return l10n.bookTypeOther;
    case null:
      return l10n.bookTypeUnknown;
  }
}
