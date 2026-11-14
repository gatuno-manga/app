import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/network/dio_client.dart';
import 'package:gatuno/core/network/exceptions.dart';
import 'package:gatuno/features/certificates/domain/use_cases/certificates_service.dart';
import 'package:gatuno/features/downloads/data/data_sources/download_remote_data_source.dart';
import 'package:gatuno/features/downloads/exceptions/download_exceptions.dart';
import 'package:mocktail/mocktail.dart';

class MockCertificatesService extends Mock implements CertificatesService {}

/// Answers every request with [status] and [body].
class _StatusAdapter implements HttpClientAdapter {
  final int status;
  final Object body;
  RequestOptions? last;

  _StatusAdapter(this.status, [this.body = const {}]);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
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
  late DioClient client;

  DownloadRemoteDataSource source(String baseUrl, [_StatusAdapter? adapter]) {
    client = DioClient(
      certificatesService: MockCertificatesService(),
      baseUrl: baseUrl,
    );
    if (adapter != null) client.dio.httpClientAdapter = adapter;
    return DownloadRemoteDataSource(client);
  }

  group('resolve', () {
    test('keeps a base path, as Dio and the readers do', () {
      final remote = source('http://localhost:3000/api');
      expect(
        remote.resolve('/s3/c1/1.webp'),
        'http://localhost:3000/api/s3/c1/1.webp',
      );
    });

    test('works without a base path and leaves absolute URLs alone', () {
      final remote = source('https://manga.example');
      expect(remote.resolve('/s3/1.jpg'), 'https://manga.example/s3/1.jpg');
      expect(
        remote.resolve('https://cdn.example/1.jpg'),
        'https://cdn.example/1.jpg',
      );
    });
  });

  test('file headers carry the client headers', () {
    final remote = source('https://manga.example');
    expect(remote.fileHeaders, containsPair('x-client-platform', 'mobile'));
  });

  group('fetchManifest', () {
    test('returns the raw response', () async {
      final adapter = _StatusAdapter(200, {'id': 'c1'});
      final remote = source('https://manga.example', adapter);

      expect(await remote.fetchManifest('c1'), {'id': 'c1'});
      expect(adapter.last!.path, '/chapters/c1');
      expect(
        adapter.last!.receiveTimeout,
        DownloadRemoteDataSource.manifestReceiveTimeout,
      );
    });

    test('404 is an unavailable chapter', () {
      final remote = source('https://manga.example', _StatusAdapter(404));
      expect(
        remote.fetchManifest('c1'),
        throwsA(isA<ChapterUnavailableException>()),
      );
    });

    for (final status in DownloadRemoteDataSource.transientStatuses) {
      test('$status is transient', () {
        final remote = source('https://manga.example', _StatusAdapter(status));
        expect(
          remote.fetchManifest('c1'),
          throwsA(isA<TransientServerException>()),
        );
      });
    }

    test('401 stays an UnauthorizedException', () {
      final remote = source('https://manga.example', _StatusAdapter(401));
      expect(remote.fetchManifest('c1'), throwsA(isA<UnauthorizedException>()));
    });
  });
}
