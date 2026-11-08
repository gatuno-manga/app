import '../entities/author.dart';
import '../entities/book.dart';
import '../entities/book_page_options.dart';
import '../entities/chapter.dart';
import '../entities/chapter_page_options.dart';
import '../entities/tag.dart';
import '../value_objects/book_id.dart';

abstract class BooksRepository {
  Future<BookList> getBooks(BookPageOptions options);
  Future<List<Tag>> getTags();
  Future<List<Author>> getAuthors();
  Future<Book> getBook(BookId bookId);
  Future<ChapterList> getBookChapters(
    BookId bookId,
    ChapterPageOptions options,
  );
}
