import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/image/image_loading_strategy.dart';
import 'package:gatuno/features/downloads/data/data_sources/downloaded_file_image_loading_strategy.dart';
import 'package:gatuno/features/downloads/domain/repositories/downloaded_content.dart';
import 'package:mocktail/mocktail.dart';

class MockDownloadedContent extends Mock implements DownloadedContent {}

class _RecordingStrategy implements ImageLoadingStrategy {
  final List<String> urls = [];
  final Uint8List bytes = Uint8List.fromList([9, 9]);

  @override
  Future<Uint8List?> loadImage(
    String url, {
    void Function(Size)? onImageLoaded,
  }) async {
    urls.add(url);
    return bytes;
  }
}

void main() {
  late MockDownloadedContent downloads;
  late _RecordingStrategy fallback;
  late DownloadedFileImageLoadingStrategy strategy;
  late Directory dir;

  const page = '/s3/book/1.jpg';

  setUp(() {
    downloads = MockDownloadedContent();
    fallback = _RecordingStrategy();
    strategy = DownloadedFileImageLoadingStrategy(downloads, fallback);
    dir = Directory.systemTemp.createTempSync('gatuno-downloaded-image');
  });

  tearDown(() => dir.deleteSync(recursive: true));

  test('a downloaded page loads from disk', () async {
    final file = File('${dir.path}/0001.jpg')..writeAsBytesSync([1, 2, 3]);
    when(() => downloads.localFile(page)).thenAnswer((_) async => file);

    final bytes = await strategy.loadImage(page);

    expect(bytes, [1, 2, 3]);
    expect(fallback.urls, isEmpty);
  });

  test('a page that is not downloaded goes to the next link', () async {
    when(() => downloads.localFile(page)).thenAnswer((_) async => null);

    final bytes = await strategy.loadImage(page);

    expect(bytes, fallback.bytes);
    expect(fallback.urls, [page]);
  });

  test('a file gone from disk goes to the next link', () async {
    when(
      () => downloads.localFile(page),
    ).thenAnswer((_) async => File('${dir.path}/missing.jpg'));

    final bytes = await strategy.loadImage(page);

    expect(bytes, fallback.bytes);
  });

  test('a failed lookup goes to the next link', () async {
    when(() => downloads.localFile(page)).thenThrow(StateError('db closed'));

    expect(await strategy.loadImage(page), fallback.bytes);
  });

  test('URLs outside object storage skip the lookup', () async {
    const avatar = 'https://example.com/avatar.png';

    final bytes = await strategy.loadImage(avatar);

    expect(bytes, fallback.bytes);
    verifyNever(() => downloads.localFile(any()));
  });
}
