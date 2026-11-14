import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/exceptions.dart';
import '../../../../core/logging/logger.dart';
import '../../../../core/offline/read_through.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/entities/book_page_options.dart';
import '../../domain/entities/chapter_page_options.dart';
import '../../domain/repositories/books_repository.dart';
import '../../domain/value_objects/book_id.dart';
import '../../domain/entities/author.dart';
import '../../domain/entities/tag.dart';
import '../data_sources/books_local_data_source.dart';
import '../models/author_model.dart';
import '../models/book_model.dart';
import '../models/tag_model.dart';
import '../models/chapter_model.dart';

/// Read-through: every read goes to the network first and is written to the
/// offline cache; offline, it is answered from that cache (see [ReadThrough]).
class BooksRepositoryImpl implements BooksRepository {
  final DioClient _dioClient;
  final BooksLocalDataSource _local;
  final ReadThrough _readThrough;
  static const String _logTag = 'BooksRepository';

  BooksRepositoryImpl(
    this._dioClient, {
    required BooksLocalDataSource local,
    required ReadThrough readThrough,
  }) : _local = local,
       _readThrough = readThrough;

  @override
  Future<BookList> getBooks(BookPageOptions options) => _readThrough(
    fetch: () => _fetchBooks(options),
    save: (list) => _local.saveBookList(list.data, options: options),
    load: () => _local.queryBooks(options),
  );

  @override
  Future<List<Tag>> getTags() => _readThrough(
    fetch: () => _getList(ApiConstants.tags, TagModel.fromJson),
    save: _local.saveTags,
    load: _local.getTags,
  );

  @override
  Future<List<Author>> getAuthors() => _readThrough(
    fetch: () => _getList(ApiConstants.authors, AuthorModel.fromJson),
    save: _local.saveAuthors,
    load: _local.getAuthors,
  );

  @override
  Future<Book> getBook(BookId bookId) => _readThrough(
    fetch: () => _fetchBook(bookId),
    save: _local.saveBook,
    load: () => _local.getBook(bookId),
  );

  @override
  Future<ChapterList> getBookChapters(
    BookId bookId,
    ChapterPageOptions options,
  ) => _readThrough(
    fetch: () => _fetchBookChapters(bookId, options),
    save: (list) => _local.saveChapters(
      bookId,
      list.data,
      complete: options.cursor == null && !list.hasNextPage,
    ),
    load: () => _local.getChapters(bookId, options),
  );

  Future<BookListModel> _fetchBooks(BookPageOptions options) {
    AppLogger.i('Fetching books with options: ${options.toJson()}', _logTag);
    return _get<Map<String, dynamic>, BookListModel>(
      ApiConstants.books,
      what: 'books',
      query: options.toJson(),
      parse: BookListModel.fromJson,
    );
  }

  Future<List<T>> _getList<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
  ) => _get<List<dynamic>, List<T>>(
    path,
    what: path,
    parse: (data) => [
      for (final item in data) fromJson(item as Map<String, dynamic>),
    ],
  );

  Future<BookModel> _fetchBook(BookId bookId) {
    AppLogger.i('Fetching book with ID: ${bookId.value}', _logTag);
    return _get<Map<String, dynamic>, BookModel>(
      '${ApiConstants.books}/${bookId.value}',
      what: 'book',
      parse: BookModel.fromJson,
    );
  }

  Future<ChapterListModel> _fetchBookChapters(
    BookId bookId,
    ChapterPageOptions options,
  ) {
    AppLogger.i(
      'Fetching chapters for book: ${bookId.value}, options: ${options.toJson()}',
      _logTag,
    );
    return _get<Map<String, dynamic>, ChapterListModel>(
      '${ApiConstants.books}/${bookId.value}/chapters',
      what: 'chapters',
      query: options.toJson(),
      parse: ChapterListModel.fromJson,
    );
  }

  /// GETs [path] and parses a 200 body of type [R]. Network errors become
  /// [AppExceptions] (a `NetworkException` when the server is unreachable,
  /// which [ReadThrough] turns into a cache read).
  Future<T> _get<R, T>(
    String path, {
    required String what,
    required T Function(R data) parse,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dioClient.dio.get<R>(
        path,
        queryParameters: query,
      );
      final data = response.data;
      if (response.statusCode == 200 && data is R) {
        return parse(data);
      }
      throw ServerException(
        message: 'Failed to fetch $what: Invalid response format',
        statusCode: response.statusCode,
      );
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      AppLogger.e(
        'DioException fetching $what: ${e.message}',
        e,
        e.stackTrace,
        _logTag,
      );
      throw ApiExceptionHandler.handle(e);
    } catch (e, stackTrace) {
      AppLogger.e('Unexpected error fetching $what', e, stackTrace, _logTag);
      throw Exception('An unexpected error occurred while fetching $what');
    }
  }
}
