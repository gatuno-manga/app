import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/shared/utils/image_aspect_ratio_cache.dart';

void main() {
  group('ImageAspectRatioCache', () {
    setUp(() {
      ImageAspectRatioCache.clear();
    });

    test('starts empty', () {
      expect(ImageAspectRatioCache.get('test_url'), isNull);
    });

    test('sets and gets aspect ratio', () {
      ImageAspectRatioCache.set('test_url', 1.5);
      expect(ImageAspectRatioCache.get('test_url'), 1.5);
    });

    test('updateFromSize calculates and saves aspect ratio', () {
      final ratio = ImageAspectRatioCache.updateFromSize(
        'test_url',
        const Size(300, 200),
      );
      expect(ratio, 1.5);
      expect(ImageAspectRatioCache.get('test_url'), 1.5);
    });

    test('clear removes all entries', () {
      ImageAspectRatioCache.set('url1', 1.0);
      ImageAspectRatioCache.set('url2', 2.0);

      ImageAspectRatioCache.clear();

      expect(ImageAspectRatioCache.get('url1'), isNull);
      expect(ImageAspectRatioCache.get('url2'), isNull);
    });

    test('overwrites existing entries', () {
      ImageAspectRatioCache.set('test_url', 1.0);
      ImageAspectRatioCache.set('test_url', 2.0);
      expect(ImageAspectRatioCache.get('test_url'), 2.0);
    });
  });
}
