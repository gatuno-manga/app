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
    save: (list) => _local.saveChapters(bookId, list.data),
    load: () => _local.getChapters(bookId, options),
  );

  Future<BookListModel> _fetchBooks(BookPageOptions options) async {
    AppLogger.i('Fetching books with options: ${options.toJson()}', _logTag);
    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        ApiConstants.books,
        queryParameters: options.toJson(),
      );

      final data = response.data;
      if (response.statusCode == 200 && data is Map<String, dynamic>) {
        return BookListModel.fromJson(data);
      } else {
        throw ServerException(
          message: 'Failed to fetch books: Invalid response format',
          statusCode: response.statusCode,
        );
      }
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      AppLogger.e(
        'DioException fetching books: ${e.message}',
        e,
        e.stackTrace,
        _logTag,
      );
      throw ApiExceptionHandler.handle(e);
    } catch (e, stackTrace) {
      AppLogger.e('Unexpected error fetching books', e, stackTrace, _logTag);
      throw Exception('An unexpected error occurred while fetching books');
    }
  }

  Future<List<T>> _getList<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await _dioClient.dio.get<List<dynamic>>(path);
      final data = response.data;
      if (response.statusCode == 200 && data is List) {
        return [
          for (final item in data) fromJson(item as Map<String, dynamic>),
        ];
      }
      throw ServerException(
        message: 'Failed to fetch $path: Invalid response format',
        statusCode: response.statusCode,
      );
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      AppLogger.e(
        'DioException fetching $path: ${e.message}',
        e,
        e.stackTrace,
        _logTag,
      );
      throw ApiExceptionHandler.handle(e);
    } catch (e, stackTrace) {
      AppLogger.e('Unexpected error fetching $path', e, stackTrace, _logTag);
      throw Exception('An unexpected error occurred while fetching $path');
    }
  }

  Future<BookModel> _fetchBook(BookId bookId) async {
    AppLogger.i('Fetching book with ID: ${bookId.value}', _logTag);
    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        '${ApiConstants.books}/${bookId.value}',
      );

      final data = response.data;
      if (response.statusCode == 200 && data is Map<String, dynamic>) {
        return BookModel.fromJson(data);
      } else {
        throw ServerException(
          message: 'Failed to fetch book: Invalid response format',
          statusCode: response.statusCode,
        );
      }
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      AppLogger.e(
        'DioException fetching book: ${e.message}',
        e,
        e.stackTrace,
        _logTag,
      );
      throw ApiExceptionHandler.handle(e);
    } catch (e, stackTrace) {
      AppLogger.e('Unexpected error fetching book', e, stackTrace, _logTag);
      throw Exception('An unexpected error occurred while fetching book');
    }
  }

  Future<ChapterListModel> _fetchBookChapters(
    BookId bookId,
    ChapterPageOptions options,
  ) async {
    AppLogger.i(
      'Fetching chapters for book: ${bookId.value}, options: ${options.toJson()}',
      _logTag,
    );
    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        '${ApiConstants.books}/${bookId.value}/chapters',
        queryParameters: options.toJson(),
      );

      final data = response.data;
      if (response.statusCode == 200 && data is Map<String, dynamic>) {
        return ChapterListModel.fromJson(data);
      } else {
        throw ServerException(
          message: 'Failed to fetch chapters: Invalid response format',
          statusCode: response.statusCode,
        );
      }
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      AppLogger.e(
        'DioException fetching chapters: ${e.message}',
        e,
        e.stackTrace,
        _logTag,
      );
      throw ApiExceptionHandler.handle(e);
    } catch (e, stackTrace) {
      AppLogger.e('Unexpected error fetching chapters', e, stackTrace, _logTag);
      throw Exception('An unexpected error occurred while fetching chapters');
    }
  }
}
