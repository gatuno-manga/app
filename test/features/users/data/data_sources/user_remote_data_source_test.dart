import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/users/data/data_sources/user_remote_data_source.dart';
import 'package:gatuno/features/users/domain/value_objects/profile_image_failure.dart';
import 'package:gatuno/features/users/domain/value_objects/profile_image_kind.dart';

class _FakeAdapter implements HttpClientAdapter {
  RequestOptions? last;
  int status = 200;
  String body = '{"data":{"id":"1","profileImageUrl":"http://x/a.webp"}}';

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString(
      body,
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
  late _FakeAdapter adapter;
  late UserRemoteDataSource source;

  setUp(() {
    adapter = _FakeAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://api.test'))
      ..httpClientAdapter = adapter;
    source = UserRemoteDataSource(dio);
  });

  test('fetchMe unwraps the data envelope', () async {
    final me = await source.fetchMe();
    expect(adapter.last!.path, '/users/me');
    expect(me['profileImageUrl'], 'http://x/a.webp');
  });

  test(
    'uploadImage PATCHes multipart field "file" to the kind route',
    () async {
      await source.uploadImage(
        kind: ProfileImageKind.banner,
        bytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'b.png',
      );
      expect(adapter.last!.method, 'PATCH');
      expect(adapter.last!.path, '/users/me/banner');
      final form = adapter.last!.data as FormData;
      expect(form.files.single.key, 'file');
      expect(form.files.single.value.contentType.toString(), 'image/png');
    },
  );

  for (final entry in {
    400: ProfileImageFailureReason.unsupportedType,
    413: ProfileImageFailureReason.tooLarge,
    401: ProfileImageFailureReason.forbidden,
    403: ProfileImageFailureReason.forbidden,
    500: ProfileImageFailureReason.unknown,
  }.entries) {
    test('maps HTTP ${entry.key} to ${entry.value}', () async {
      adapter
        ..status = entry.key
        ..body = '{}';
      await expectLater(
        source.uploadImage(
          kind: ProfileImageKind.avatar,
          bytes: Uint8List(1),
          fileName: 'a.png',
        ),
        throwsA(
          isA<ProfileImageFailure>().having(
            (f) => f.reason,
            'reason',
            entry.value,
          ),
        ),
      );
    });
  }
}
