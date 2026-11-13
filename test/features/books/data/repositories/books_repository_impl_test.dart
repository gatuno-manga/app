import 'package:dio/dio.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/network/api_constants.dart';
import 'package:gatuno/core/network/dio_client.dart';
import 'package:gatuno/core/network/exceptions.dart';
import 'package:gatuno/features/books/data/repositories/books_repository_impl.dart';
import 'package:gatuno/features/books/domain/entities/book_page_options.dart';
import 'package:gatuno/features/books/domain/entities/chapter_page_options.dart';
import 'package:mocktail/mocktail.dart';
import 'package:drift/native.dart';
import 'package:gatuno/core/connectivity/connectivity_service.dart';
import 'package:gatuno/core/database/offline_cache_database.dart';
import 'package:gatuno/core/offline/read_through.dart';
import 'package:gatuno/features/books/data/data_sources/books_local_data_source.dart';

class MockDioClient extends Mock implements DioClient {}

class MockDio extends Mock implements Dio {}

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late BooksRepositoryImpl repository;
  late MockDioClient mockDioClient;
  late MockDio mockDio;
  late OfflineCacheDatabase db;
  late MockConnectivityService connectivity;

  setUpAll(() {
    registerFallbackValue(BookId('dummy'));
    registerFallbackValue(const BookPageOptions());
  });

  setUp(() {
    mockDioClient = MockDioClient();
    mockDio = MockDio();
    when(() => mockDioClient.dio).thenReturn(mockDio);
    db = OfflineCacheDatabase(NativeDatabase.memory());
    connectivity = MockConnectivityService();
    when(() => connectivity.status).thenReturn(ConnectivityStatus.online);
    repository = BooksRepositoryImpl(
      mockDioClient,
      local: BooksLocalDataSource(db),
      readThrough: ReadThrough(connectivity),
    );
  });

  tearDown(() => db.close());

  group('read-through', () {
    const options = BookPageOptions();
    final bookJson = {
      'id': '1',
      'title': 'Book 1',
      'cover': 'https://s3/books/1.webp',
      'tags': [
        {'id': 't1', 'name': 'Action'},
      ],
      'authors': [
        {'id': 'a1', 'name': 'Oda'},
      ],
      'sensitiveContent': [
        {'id': 's1', 'name': 'Gore', 'weight': 2},
      ],
    };

    void stubBook() {
      when(() => mockDio.get<Map<String, dynamic>>('/books/1')).thenAnswer(
        (_) async => Response(
          data: bookJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/books/1'),
        ),
      );
    }

    DioException unreachable(String path) => DioException(
      requestOptions: RequestOptions(path: path),
      type: DioExceptionType.connectionError,
    );

    test('a book fetched online is served offline', () async {
      stubBook();
      await repository.getBook(const BookId('1'));

      when(() => connectivity.status).thenReturn(ConnectivityStatus.offline);
      final cached = await repository.getBook(const BookId('1'));

      expect(cached.title.value, 'Book 1');
      expect(cached.tags.single.name.value, 'Action');
      expect(cached.authors.single.name.value, 'Oda');
      expect(cached.sensitiveContent, ['Gore']);
      verify(() => mockDio.get<Map<String, dynamic>>('/books/1')).called(1);
    });

    test('a connection error falls back to the cache', () async {
      stubBook();
      await repository.getBook(const BookId('1'));
      when(
        () => mockDio.get<Map<String, dynamic>>('/books/1'),
      ).thenThrow(unreachable('/books/1'));

      final cached = await repository.getBook(const BookId('1'));

      expect(cached.id.value, '1');
    });

    test('offline with nothing cached throws OfflineException', () {
      when(() => connectivity.status).thenReturn(ConnectivityStatus.offline);

      expect(
        repository.getBook(const BookId('1')),
        throwsA(isA<OfflineException>()),
      );
      expect(repository.getBooks(options), throwsA(isA<OfflineException>()));
      expect(repository.getTags(), throwsA(isA<OfflineException>()));
      expect(repository.getAuthors(), throwsA(isA<OfflineException>()));
      expect(
        repository.getBookChapters(
          const BookId('1'),
          const ChapterPageOptions(),
        ),
        throwsA(isA<OfflineException>()),
      );
    });

    test('a server error is not treated as offline', () async {
      stubBook();
      await repository.getBook(const BookId('1'));
      when(() => mockDio.get<Map<String, dynamic>>('/books/1')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/books/1'),
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: '/books/1'),
          ),
        ),
      );

      expect(
        repository.getBook(const BookId('1')),
        throwsA(isA<ServerException>()),
      );
    });

    test('lists, chapters, tags and authors are served offline', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          ApiConstants.books,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'data': [bookJson],
            'metadata': {'total': 1, 'page': 1, 'limit': 20, 'lastPage': 1},
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiConstants.books),
        ),
      );
      when(
        () => mockDio.get<Map<String, dynamic>>(
          '/books/1/chapters',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'data': [
              {'id': 'c1', 'title': 'One', 'index': 1},
            ],
            'nextCursor': null,
            'hasNextPage': false,
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/books/1/chapters'),
        ),
      );
      for (final path in [ApiConstants.tags, ApiConstants.authors]) {
        when(() => mockDio.get<List<dynamic>>(path)).thenAnswer(
          (_) async => Response(
            data: [
              {'id': 'x1', 'name': 'X'},
            ],
            statusCode: 200,
            requestOptions: RequestOptions(path: path),
          ),
        );
      }
      await repository.getBooks(options);
      await repository.getBookChapters(
        const BookId('1'),
        const ChapterPageOptions(),
      );
      await repository.getTags();
      await repository.getAuthors();

      when(() => connectivity.status).thenReturn(ConnectivityStatus.offline);

      expect((await repository.getBooks(options)).data.single.id.value, '1');
      expect(
        (await repository.getBookChapters(
          const BookId('1'),
          const ChapterPageOptions(),
        )).data.single.id.value,
        'c1',
      );
      expect((await repository.getTags()).single.name.value, 'X');
      expect((await repository.getAuthors()).single.name.value, 'X');
    });
  });

  group('getTags / getAuthors', () {
    test('getTags parses the list response', () async {
      when(() => mockDio.get<List<dynamic>>(ApiConstants.tags)).thenAnswer(
        (_) async => Response(
          data: [
            {'id': 't1', 'name': 'Action'},
          ],
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiConstants.tags),
        ),
      );

      final result = await repository.getTags();

      expect(result.single.id.value, 't1');
      expect(result.single.name.value, 'Action');
    });

    test('getAuthors parses the list response', () async {
      when(() => mockDio.get<List<dynamic>>(ApiConstants.authors)).thenAnswer(
        (_) async => Response(
          data: [
            {'id': 'a1', 'name': 'Oda'},
          ],
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiConstants.authors),
        ),
      );

      final result = await repository.getAuthors();

      expect(result.single.id.value, 'a1');
      expect(result.single.name.value, 'Oda');
    });

    test('getTags throws on an unexpected response', () async {
      when(() => mockDio.get<List<dynamic>>(ApiConstants.tags)).thenAnswer(
        (_) async => Response(
          data: null,
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiConstants.tags),
        ),
      );

      expect(() => repository.getTags(), throwsA(isA<ServerException>()));
    });
  });

  group('getBooks', () {
    const options = BookPageOptions();
    final bookListJson = {
      'data': [
        {'id': '1', 'title': 'Book 1'},
      ],
      'metadata': {'total': 1, 'page': 1, 'limit': 20, 'lastPage': 1},
    };

    test('should return BookListModel when the call is successful', () async {
      // arrange
      when(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: bookListJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiConstants.books),
        ),
      );

      // act
      final result = await repository.getBooks(options);

      // assert
      expect(result.data.length, 1);
      expect(result.data[0].id.value, '1');
      expect(result.total.value, 1);
    });

    test(
      'should throw ServerException when response format is invalid',
      () async {
        // arrange
        when(
          () => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: null,
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiConstants.books),
          ),
        );

        // act
        final call = repository.getBooks(options);

        // assert
        expect(call, throwsA(isA<ServerException>()));
      },
    );

    test('should throw ServerException when statusCode is not 200', () async {
      // arrange
      when(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: bookListJson,
          statusCode: 500,
          requestOptions: RequestOptions(path: ApiConstants.books),
        ),
      );

      // act
      final call = repository.getBooks(options);

      // assert
      expect(call, throwsA(isA<ServerException>()));
    });

    test(
      'throws OfflineException when the server is unreachable and nothing is cached',
      () async {
        // arrange
        when(
          () => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ApiConstants.books),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        // act
        final call = repository.getBooks(options);

        // assert
        expect(call, throwsA(isA<OfflineException>()));
      },
    );

    test(
      'should throw generic Exception when an unexpected error occurs',
      () async {
        // arrange
        when(
          () => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenThrow(Exception('Unexpected error'));

        // act
        final call = repository.getBooks(options);

        // assert
        expect(call, throwsA(isA<Exception>()));
      },
    );
  });

  group('getBook', () {
    const bookId = BookId('1');
    final bookJson = {'id': '1', 'title': 'Book 1'};

    test('should return BookModel when the call is successful', () async {
      // arrange
      when(() => mockDio.get<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => Response(
          data: bookJson,
          statusCode: 200,
          requestOptions: RequestOptions(
            path: '${ApiConstants.books}/${bookId.value}',
          ),
        ),
      );

      // act
      final result = await repository.getBook(bookId);

      // assert
      expect(result.id.value, '1');
      expect(result.title.value, 'Book 1');
    });

    test(
      'should throw ServerException when response format is invalid',
      () async {
        // arrange
        when(() => mockDio.get<Map<String, dynamic>>(any())).thenAnswer(
          (_) async => Response(
            data: null,
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '${ApiConstants.books}/${bookId.value}',
            ),
          ),
        );

        // act
        final call = repository.getBook(bookId);

        // assert
        expect(call, throwsA(isA<ServerException>()));
      },
    );

    test(
      'throws OfflineException when the server is unreachable and nothing is cached',
      () async {
        when(() => mockDio.get<Map<String, dynamic>>(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(path: ''),
            ),
          ),
        );

        expect(() => repository.getBook(bookId), throwsA(isA<AuthException>()));
      },
    );

    test('should throw generic Exception on unexpected error', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(any()),
      ).thenThrow(Exception());

      expect(() => repository.getBook(bookId), throwsA(isA<Exception>()));
    });
  });

  group('getBookChapters', () {
    const bookId = BookId('1');
    const options = ChapterPageOptions();
    final chapterListJson = {
      'data': [
        {'id': '1', 'index': 1.0},
      ],
      'hasNextPage': false,
    };

    test(
      'should return ChapterListModel when the call is successful',
      () async {
        // arrange
        when(
          () => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: chapterListJson,
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '${ApiConstants.books}/${bookId.value}/chapters',
            ),
          ),
        );

        // act
        final result = await repository.getBookChapters(bookId, options);

        // assert
        expect(result.data.length, 1);
        expect(result.data[0].id.value, '1');
        expect(result.hasNextPage, false);
      },
    );

    test('should throw ServerException when response is invalid', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: null,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      expect(
        () => repository.getBookChapters(bookId, options),
        throwsA(isA<ServerException>()),
      );
    });

    test(
      'throws OfflineException when unreachable and nothing is cached',
      () async {
        when(
          () => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        expect(
          () => repository.getBookChapters(bookId, options),
          throwsA(isA<OfflineException>()),
        );
      },
    );

    test('should throw generic Exception on unexpected error', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(Exception());

      expect(
        () => repository.getBookChapters(bookId, options),
        throwsA(isA<Exception>()),
      );
    });
  });
}
