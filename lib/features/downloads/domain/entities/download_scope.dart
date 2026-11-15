import 'package:equatable/equatable.dart';

import '../../../books/domain/value_objects/book_id.dart';
import '../../../books/domain/value_objects/chapter_id.dart';

/// Which downloads a pause, resume, retry or delete acts on.
sealed class DownloadScope extends Equatable {
  const DownloadScope();

  const factory DownloadScope.chapters(List<ChapterId> chapterIds) =
      ChaptersScope;
  const factory DownloadScope.book(BookId bookId) = BookScope;
  const factory DownloadScope.all() = AllScope;
}

class ChaptersScope extends DownloadScope {
  final List<ChapterId> chapterIds;

  const ChaptersScope(this.chapterIds);

  @override
  List<Object?> get props => [chapterIds];
}

class BookScope extends DownloadScope {
  final BookId bookId;

  const BookScope(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

class AllScope extends DownloadScope {
  const AllScope();

  @override
  List<Object?> get props => const [];
}
