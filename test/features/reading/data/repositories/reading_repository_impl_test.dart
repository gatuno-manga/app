import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/network/dio_client.dart';
import 'package:gatuno/core/network/exceptions.dart';
import 'package:gatuno/features/reading/data/repositories/reading_repository_impl.dart';
import 'package:gatuno/features/reading/data/models/reading_chapter_model.dart';
import 'package:mocktail/mocktail.dart';

class MockDioClient extends Mock implements DioClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late ReadingRepositoryImpl repository;
  late MockDioClient mockDioClient;
  late MockDio mockDio;

  setUp(() {
    mockDioClient = MockDioClient();
    mockDio = MockDio();
    when(() => mockDioClient.dio).thenReturn(mockDio);
    repository = ReadingRepositoryImpl(mockDioClient);
  });

  group('ReadingRepositoryImpl', () {
    const chapterId = 'chapter-1';

    test('getChapter returns ReadingChapterModel on success', () async {
      final responseData = {
        'id': chapterId,
        'title': 'Chapter 1',
        'originalUrl': 'http://example.com',
        'index': 1,
        'contentType': 'image',
        'retries': 0,
        'isFinal': true,
        'bookId': 'book-1',
        'bookTitle': 'Book 1',
        'totalChapters': 10,
        'pages': [
          {'id': 'p1', 'url': 'p1.jpg', 'index': 0},
        ],
        'comments': <Map<String, dynamic>>[],
      };

      when(() => mockDio.get<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await repository.getChapter(chapterId);

      expect(result.id, chapterId);
      expect(result.title, 'Chapter 1');
      expect(result, isA<ReadingChapterModel>());
      verify(() => mockDio.get<Map<String, dynamic>>(any())).called(1);
    });

    test(
      'getChapter throws ServerException when response is not 200',
      () async {
        when(() => mockDio.get<Map<String, dynamic>>(any())).thenAnswer(
          (_) async => Response(
            data: {},
            statusCode: 404,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        expect(
          () => repository.getChapter(chapterId),
          throwsA(isA<ServerException>()),
        );
      },
    );

    test('getChapter throws ServerException when data is not Map', () async {
      when(() => mockDio.get<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => Response(
          data: null,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      expect(
        () => repository.getChapter(chapterId),
        throwsA(isA<ServerException>()),
      );
    });

    test('getChapter throws handled ApiException on DioException', () async {
      when(() => mockDio.get<Map<String, dynamic>>(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      expect(
        () => repository.getChapter(chapterId),
        throwsA(isA<NetworkException>()),
      );
    });

    test('getChapter rethrows ServerException', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(any()),
      ).thenThrow(ServerException(message: 'Server Error'));

      expect(
        () => repository.getChapter(chapterId),
        throwsA(isA<ServerException>()),
      );
    });

    test('getChapter throws generic Exception on unexpected error', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(any()),
      ).thenThrow(Exception('Unexpected'));

      expect(() => repository.getChapter(chapterId), throwsA(isA<Exception>()));
    });
  });
}
