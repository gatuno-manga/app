import 'dart:math';

import 'package:dio/dio.dart';

import '../../../../core/logging/logger.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/exceptions.dart';
import '../../../books/domain/value_objects/book_id.dart';
import '../../../books/domain/value_objects/chapter_id.dart';
import '../../domain/entities/listed_chapter.dart';
import '../../domain/repositories/new_chapter_source.dart';

/// [NewChapterSource] over the API's GraphQL endpoint: one request lists
/// every chapter of up to [NewChapterSource.maxBooks] books.
///
/// `Book.chapters` without a filter loads the chapters of every listed book
/// in one query on the server, in every language, with no paging. Only ids
/// and scraping states are asked for; `GET /chapters/:id` is never called
/// here.
class GraphqlNewChapterSource implements NewChapterSource {
  final DioClient _dioClient;

  static const String _logTag = 'GraphqlNewChapterSource';

  /// The server rejects a page smaller than this.
  static const int _minLimit = 5;

  static const String query = r'''
query NewChapters($filter: BookFilterInput) {
  books(filter: $filter) {
    data {
      id
      chapters {
        data {
          id
          scrapingStatus
        }
      }
    }
  }
}''';

  GraphqlNewChapterSource(this._dioClient);

  @override
  Future<Map<BookId, List<ListedChapter>>> chaptersOf(
    List<BookId> bookIds,
  ) async {
    assert(bookIds.length <= NewChapterSource.maxBooks);
    if (bookIds.isEmpty) return const {};
    final Response<Map<String, dynamic>> response;
    try {
      response = await _dioClient.dio.post<Map<String, dynamic>>(
        ApiConstants.graphql,
        data: {
          'query': query,
          'variables': {
            'filter': {
              'ids': [for (final id in bookIds) id.value],
              'limit': max(bookIds.length, _minLimit),
            },
          },
        },
      );
    } on DioException catch (e) {
      throw ApiExceptionHandler.handle(e);
    }
    return parse(response.data);
  }

  /// The books of a GraphQL response body, by id.
  static Map<BookId, List<ListedChapter>> parse(Map<String, dynamic>? body) {
    final errors = body?['errors'];
    final books = switch (body?['data']) {
      {'books': {'data': final List<dynamic> data}} => data,
      _ => null,
    };
    if (books == null) {
      throw ServerException(message: 'GraphQL books query failed: $errors');
    }
    if (errors is List && errors.isNotEmpty) {
      AppLogger.w('GraphQL books query answered with errors: $errors', _logTag);
    }
    return {
      for (final book in books.whereType<Map<String, dynamic>>())
        if (book case {
          'id': final String id,
          'chapters': {'data': final List<dynamic> chapters},
        })
          BookId(id): [
            for (final chapter in chapters.whereType<Map<String, dynamic>>())
              if (chapter['id'] case final String chapterId)
                ListedChapter(
                  id: ChapterId(chapterId),
                  ready: _isReady(chapter['scrapingStatus']),
                ),
          ],
    };
  }

  /// Same rule as `Chapter.isReadable`: no status means nothing to scrape.
  static bool _isReady(Object? status) =>
      status == null || status.toString().toUpperCase() == 'READY';
}
