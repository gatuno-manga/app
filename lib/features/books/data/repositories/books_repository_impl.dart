import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/exceptions.dart';
import '../../../../core/logging/logger.dart';
import '../../domain/entities/book_page_options.dart';
import '../../domain/entities/chapter_page_options.dart';
import '../../domain/repositories/books_repository.dart';
import '../../domain/value_objects/book_id.dart';
import '../../domain/entities/author.dart';
import '../../domain/entities/tag.dart';
import '../models/author_model.dart';
import '../models/book_model.dart';
import '../models/tag_model.dart';
import '../models/chapter_model.dart';

class BooksRepositoryImpl implements BooksRepository {
  final DioClient _dioClient;
  static const String _logTag = 'BooksRepository';

  BooksRepositoryImpl(this._dioClient);

  @override
  Future<BookListModel> getBooks(BookPageOptions options) async {
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

  @override
  Future<List<Tag>> getTags() => _getList(ApiConstants.tags, TagModel.fromJson);

  @override
  Future<List<Author>> getAuthors() =>
      _getList(ApiConstants.authors, AuthorModel.fromJson);

  Future<List<T>> _getList<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await _dioClient.dio.get<List<dynamic>>(path);
      final data = response.data;
      if (response.statusCode == 200 && data is List) {
        return data
            .cast<Map<String, dynamic>>()
            .map(fromJson)
            .toList(growable: false);
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

  @override
  Future<BookModel> getBook(BookId bookId) async {
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

  @override
  Future<ChapterListModel> getBookChapters(
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
