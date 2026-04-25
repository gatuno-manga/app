import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/network/api_constants.dart';
import 'package:gatuno/core/network/dio_client.dart';
import 'package:gatuno/core/network/exceptions.dart';
import 'package:gatuno/features/reading/data/repositories/reading_repository_impl.dart';
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

  group('getChapter', () {
    const chapterId = 'chapter-123';
    final chapterJson = {
      'id': chapterId,
      'index': 1.0,
      'title': 'Chapter 1',
      'bookId': 'book-123',
      'bookTitle': 'Book Title',
      'contentType': 'image',
      'pages': [
        {'id': 'p1', 'url': 'url1'},
      ],
    };

    test(
      'should return ReadingChapterModel when the call is successful',
      () async {
        // arrange
        when(() => mockDio.get<Map<String, dynamic>>(any())).thenAnswer(
          (_) async => Response(
            data: chapterJson,
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '${ApiConstants.chapters}/$chapterId',
            ),
          ),
        );

        // act
        final result = await repository.getChapter(chapterId);

        // assert
        expect(result.id, chapterId);
        expect(result.title, 'Chapter 1');
        expect(result.bookTitle, 'Book Title');
      },
    );

    test(
      'should throw ServerException when response format is invalid',
      () async {
        // arrange
        when(() => mockDio.get<Map<String, dynamic>>(any())).thenAnswer(
          (_) async => Response(
            data: null,
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '${ApiConstants.chapters}/$chapterId',
            ),
          ),
        );

        // act & assert
        expect(
          () => repository.getChapter(chapterId),
          throwsA(isA<ServerException>()),
        );
      },
    );

    test('should throw ServerException when statusCode is not 200', () async {
      // arrange
      when(() => mockDio.get<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => Response(
          data: chapterJson,
          statusCode: 500,
          requestOptions: RequestOptions(
            path: '${ApiConstants.chapters}/$chapterId',
          ),
        ),
      );

      // act & assert
      expect(
        () => repository.getChapter(chapterId),
        throwsA(isA<ServerException>()),
      );
    });

    test(
      'should throw handled ApiException when DioException occurs',
      () async {
        // arrange
        when(() => mockDio.get<Map<String, dynamic>>(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '${ApiConstants.chapters}/$chapterId',
            ),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        // act & assert
        expect(
          () => repository.getChapter(chapterId),
          throwsA(isA<NetworkException>()),
        );
      },
    );

    test(
      'should throw generic Exception when an unexpected error occurs',
      () async {
        // arrange
        when(
          () => mockDio.get<Map<String, dynamic>>(any()),
        ).thenThrow(Exception('Unexpected error'));

        // act & assert
        expect(
          () => repository.getChapter(chapterId),
          throwsA(isA<Exception>()),
        );
      },
    );
  });
}
