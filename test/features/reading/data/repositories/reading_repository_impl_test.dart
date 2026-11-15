import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/connectivity/connectivity_service.dart';
import 'package:gatuno/core/network/dio_client.dart';
import 'package:gatuno/core/network/exceptions.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/downloads/domain/entities/downloaded_chapter.dart';
import 'package:gatuno/features/downloads/domain/repositories/downloaded_content.dart';
import 'package:gatuno/features/reading/data/models/reading_chapter_model.dart';
import 'package:gatuno/features/reading/data/repositories/reading_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_connectivity_service.dart';

class MockDioClient extends Mock implements DioClient {}

class MockDio extends Mock implements Dio {}

class MockDownloadedContent extends Mock implements DownloadedContent {}

Map<String, dynamic> _json({
  String? next,
  String updatedAt = '2026-11-01T00:00:00.000Z',
}) => {
  'id': 'chapter-1',
  'title': 'Chapter 1',
  'originalUrl': 'http://example.com',
  'index': 1,
  'contentType': 'image',
  'retries': 0,
  'isFinal': true,
  'previous': 'chapter-0',
  'next': next,
  'updatedAt': updatedAt,
  'bookId': 'book-1',
  'bookTitle': 'Book 1',
  'totalChapters': 10,
  'pages': [
    {'id': 'p1', 'url': 'p1.jpg', 'index': 0},
  ],
  'comments': <Map<String, dynamic>>[],
};

void main() {
  late ReadingRepositoryImpl repository;
  late MockDio dio;
  late MockDownloadedContent downloads;
  late FakeConnectivityService connectivity;

  const id = ChapterId('chapter-1');

  void serverAnswers(Map<String, dynamic>? data, {int status = 200}) {
    when(() => dio.get<Map<String, dynamic>>(any())).thenAnswer(
      (_) async => Response(
        data: data,
        statusCode: status,
        requestOptions: RequestOptions(path: ''),
      ),
    );
  }

  void serverThrows(Object error) {
    when(() => dio.get<Map<String, dynamic>>(any())).thenThrow(error);
  }

  setUpAll(() {
    registerFallbackValue(const ChapterId('dummy'));
  });

  setUp(() {
    final client = MockDioClient();
    dio = MockDio();
    downloads = MockDownloadedContent();
    connectivity = FakeConnectivityService();
    when(() => client.dio).thenReturn(dio);
    when(() => downloads.chapter(any())).thenAnswer((_) async => null);
    repository = ReadingRepositoryImpl(client, downloads, connectivity);
  });

  tearDown(() => connectivity.close());

  group('openChapter', () {
    test('a downloaded chapter opens from the device, online too', () async {
      final saved = ReadingChapterModel.fromJson(_json());
      when(
        () => downloads.chapter(id),
      ).thenAnswer((_) async => DownloadedChapter(chapter: saved));

      final opened = await repository.openChapter(id);

      expect(opened.isDownloaded, isTrue);
      expect(opened.chapter, same(saved));
      verifyNever(() => dio.get<Map<String, dynamic>>(any()));
    });

    test('otherwise the server answers', () async {
      serverAnswers(_json());

      final opened = await repository.openChapter(id);

      expect(opened.isDownloaded, isFalse);
      expect(opened.chapter.id, id);
      expect(opened.chapter, isA<ReadingChapterModel>());
    });

    test('a broken download falls back to the server', () async {
      when(() => downloads.chapter(id)).thenThrow(StateError('db closed'));
      serverAnswers(_json());

      final opened = await repository.openChapter(id);

      expect(opened.isDownloaded, isFalse);
    });

    test(
      'known offline and not downloaded: OfflineException, no request',
      () async {
        connectivity.goOffline();

        await expectLater(
          repository.openChapter(id),
          throwsA(isA<OfflineException>()),
        );
        verifyNever(() => dio.get<Map<String, dynamic>>(any()));
      },
    );

    test('a connection error becomes OfflineException', () async {
      serverThrows(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      await expectLater(
        repository.openChapter(id),
        throwsA(isA<OfflineException>()),
      );
    });

    test('a server error is not offline', () async {
      serverAnswers(<String, dynamic>{}, status: 404);

      await expectLater(
        repository.openChapter(id),
        throwsA(isA<ServerException>()),
      );
    });

    test('a response that is not a map is a server error', () async {
      serverAnswers(null);

      await expectLater(
        repository.openChapter(id),
        throwsA(isA<ServerException>()),
      );
    });

    test('an AppExceptions from the client is rethrown unchanged', () async {
      serverThrows(ServerException(message: 'Server Error'));

      await expectLater(
        repository.openChapter(id),
        throwsA(isA<ServerException>()),
      );
    });

    test('an unexpected error becomes a generic exception', () async {
      serverThrows(StateError('Unexpected'));

      await expectLater(repository.openChapter(id), throwsA(isA<Exception>()));
    });
  });

  group('refreshNavigation', () {
    test('takes previous and next from the server', () async {
      final saved = ReadingChapterModel.fromJson(_json());
      serverAnswers(
        _json(next: 'chapter-2', updatedAt: '2026-11-10T00:00:00.000Z'),
      );

      final refreshed = await repository.refreshNavigation(saved);

      expect(refreshed.next, const ChapterId('chapter-2'));
      expect(refreshed.previous, const ChapterId('chapter-0'));
      // Everything else stays as downloaded.
      expect(refreshed.pages, same(saved.pages));
      expect(refreshed.updatedAt, saved.updatedAt);
    });

    test('throws when the server cannot be reached', () async {
      serverThrows(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionError,
        ),
      );

      await expectLater(
        repository.refreshNavigation(ReadingChapterModel.fromJson(_json())),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('isDownloaded', () {
    test('true only for a readable download', () async {
      when(() => downloads.chapter(const ChapterId('saved'))).thenAnswer(
        (_) async =>
            DownloadedChapter(chapter: ReadingChapterModel.fromJson(_json())),
      );

      expect(await repository.isDownloaded(const ChapterId('saved')), isTrue);
      expect(await repository.isDownloaded(id), isFalse);
      expect(connectivity.status, ConnectivityStatus.online);
    });
  });
}
