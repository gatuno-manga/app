import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/covers/cover_image_loading_strategy.dart';
import 'package:gatuno/core/covers/cover_store.dart';
import 'package:gatuno/core/image/image_loading_strategy.dart';
import 'package:mocktail/mocktail.dart';

class MockCoverStore extends Mock implements CoverStore {}

class FakeStrategy implements ImageLoadingStrategy {
  final List<String> loaded = [];

  @override
  Future<Uint8List?> loadImage(
    String url, {
    void Function(Size)? onImageLoaded,
  }) async {
    loaded.add(url);
    return Uint8List.fromList([9]);
  }
}

void main() {
  late MockCoverStore store;
  late FakeStrategy fallback;
  late CoverImageLoadingStrategy strategy;
  late Directory dir;

  setUp(() {
    store = MockCoverStore();
    fallback = FakeStrategy();
    strategy = CoverImageLoadingStrategy(store, fallback);
    dir = Directory.systemTemp.createTempSync('gatuno-cover-strategy');
  });

  tearDown(() => dir.deleteSync(recursive: true));

  test('a URL that is no cached cover goes to the network', () async {
    when(
      () => store.bookIdForUrl('https://s3/page.webp'),
    ).thenAnswer((_) async => null);

    final bytes = await strategy.loadImage('https://s3/page.webp');

    expect(bytes, [9]);
    expect(fallback.loaded, ['https://s3/page.webp']);
  });

  test('a cached book cover is served from the store', () async {
    final file = File('${dir.path}/1.img')..writeAsBytesSync([1, 2, 3]);
    when(
      () => store.bookIdForUrl('https://s3/1.webp'),
    ).thenAnswer((_) async => '1');
    when(
      () => store.ensure('1', 'https://s3/1.webp'),
    ).thenAnswer((_) async => file);

    final bytes = await strategy.loadImage('https://s3/1.webp');

    expect(bytes, [1, 2, 3]);
    expect(fallback.loaded, isEmpty);
  });

  test('a cover that cannot be fetched yields no bytes', () async {
    when(() => store.bookIdForUrl(any())).thenAnswer((_) async => '1');
    when(() => store.ensure(any(), any())).thenAnswer((_) async => null);

    expect(await strategy.loadImage('https://s3/1.webp'), isNull);
    expect(fallback.loaded, isEmpty);
  });
}
