import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/network/dio_client.dart';
import 'package:gatuno/core/network/exceptions.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/certificates/domain/use_cases/certificates_service.dart';
import 'package:gatuno/features/downloads/data/repositories/graphql_new_chapter_source.dart';
import 'package:gatuno/features/downloads/domain/entities/listed_chapter.dart';
import 'package:mocktail/mocktail.dart';

class MockCertificatesService extends Mock implements CertificatesService {}

/// Answers every request with [status] and [body], keeping the request.
class _Adapter implements HttpClientAdapter {
  final int status;
  final Object body;
  RequestOptions? last;
  Object? lastBody;

  _Adapter(this.status, this.body);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    lastBody = options.data;
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  const bookA = BookId('11111111-1111-1111-1111-111111111111');
  const bookB = BookId('22222222-2222-2222-2222-222222222222');

  GraphqlNewChapterSource source(_Adapter adapter) {
    final client = DioClient(
      certificatesService: MockCertificatesService(),
      baseUrl: 'http://localhost:3000/api',
    );
    client.dio.httpClientAdapter = adapter;
    return GraphqlNewChapterSource(client);
  }

  Map<String, Object?> books(List<Map<String, Object?>> data) => {
    'data': {
      'books': {'data': data},
    },
  };

  test(
    'posts one query for every book, with ids and a page that fits',
    () async {
      final adapter = _Adapter(200, books(const []));

      await source(adapter).chaptersOf([bookA, bookB]);

      expect(adapter.last!.method, 'POST');
      expect(adapter.last!.uri.toString(), 'http://localhost:3000/api/graphql');
      final body = adapter.lastBody! as Map<String, dynamic>;
      expect(body['query'], GraphqlNewChapterSource.query);
      expect(body['variables'], {
        'filter': {
          'ids': [bookA.value, bookB.value],
          'limit': 5,
        },
      });
    },
  );

  test('maps chapters by book, ready when READY or without a status', () async {
    final adapter = _Adapter(
      200,
      books([
        {
          'id': bookA.value,
          'chapters': {
            'data': [
              {'id': 'c1', 'scrapingStatus': 'READY'},
              {'id': 'c2', 'scrapingStatus': 'PROCESS'},
              {'id': 'c3', 'scrapingStatus': 'ERROR'},
              {'id': 'c4', 'scrapingStatus': null},
            ],
          },
        },
      ]),
    );

    final result = await source(adapter).chaptersOf([bookA, bookB]);

    expect(result.keys, [bookA]);
    expect(result[bookA], const [
      ListedChapter(id: ChapterId('c1'), ready: true),
      ListedChapter(id: ChapterId('c2'), ready: false),
      ListedChapter(id: ChapterId('c3'), ready: false),
      ListedChapter(id: ChapterId('c4'), ready: true),
    ]);
  });

  test('no books: no request', () async {
    final adapter = _Adapter(200, books(const []));

    expect(await source(adapter).chaptersOf(const []), isEmpty);
    expect(adapter.last, isNull);
  });

  test('a response with errors and no data fails', () {
    final adapter = _Adapter(200, {
      'errors': [
        {'message': 'Query is too complex'},
      ],
      'data': null,
    });

    expect(
      source(adapter).chaptersOf([bookA]),
      throwsA(isA<ServerException>()),
    );
  });

  test('an HTTP error becomes an app exception', () {
    final adapter = _Adapter(500, {'message': 'boom'});

    expect(source(adapter).chaptersOf([bookA]), throwsA(isA<AppExceptions>()));
  });
}
