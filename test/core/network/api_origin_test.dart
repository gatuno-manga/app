import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/network/api_origin.dart';

void main() {
  group('isApiOrigin', () {
    test('returns true when scheme, host, and port match', () {
      final options = RequestOptions(
        path: '/books',
        baseUrl: 'https://api.gatuno.com/api',
      );

      expect(isApiOrigin(options), isTrue);
    });

    test('returns false when baseUrl is empty, malformed, or lacks host', () {
      final options = RequestOptions(path: '/books');

      expect(isApiOrigin(options, baseUrl: ''), isFalse);
      expect(isApiOrigin(options, baseUrl: 'invalid-base-url'), isFalse);
      expect(isApiOrigin(options, baseUrl: 'file:///tmp/books'), isFalse);
    });

    test('returns false when scheme, host, or port differs', () {
      const baseUrl = 'https://api.gatuno.com/api';

      expect(
        isApiOrigin(
          RequestOptions(
            path: 'https://s3.amazonaws.com/bucket/cover.jpg',
            baseUrl: baseUrl,
          ),
        ),
        isFalse,
      );
      expect(
        isApiOrigin(
          RequestOptions(
            path: 'http://api.gatuno.com/api/books',
            baseUrl: baseUrl,
          ),
        ),
        isFalse,
      );
      expect(
        isApiOrigin(
          RequestOptions(
            path: 'https://api.gatuno.com:8443/api/books',
            baseUrl: baseUrl,
          ),
        ),
        isFalse,
      );
    });
  });
}
