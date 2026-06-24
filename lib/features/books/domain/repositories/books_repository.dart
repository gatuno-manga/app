import '../entities/book.dart';
import '../entities/book_page_options.dart';
import '../entities/chapter.dart';
import '../entities/chapter_page_options.dart';
import '../value_objects/book_id.dart';

abstract class BooksRepository {
  Future<BookList> getBooks(BookPageOptions options);
  Future<Book> getBook(BookId bookId);
  Future<ChapterList> getBookChapters(
    BookId bookId,
    ChapterPageOptions options,
  );
}
