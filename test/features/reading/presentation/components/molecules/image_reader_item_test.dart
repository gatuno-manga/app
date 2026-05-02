import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/reading/domain/entities/reading_chapter.dart';
import 'package:gatuno/features/reading/presentation/components/molecules/image_reader_item.dart';
import 'package:gatuno/shared/domain/entities/image_metadata.dart';
import 'package:gatuno/shared/utils/image_aspect_ratio_cache.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../../helpers/test_injection.dart';

void main() {
  late MockDioClient mockDioClient;
  late MockDio mockDio;

  setUp(() async {
    mockDioClient = MockDioClient();
    mockDio = mockDioClient.dio as MockDio;
    await initTestDI(dioClient: mockDioClient);
    ImageAspectRatioCache.clear();
    registerFallbackValue(RequestOptions(path: ''));
  });

  Widget createWidget(ReadingPage page) {
    return MaterialApp(
      home: Scaffold(body: ImageReaderItem(page: page)),
    );
  }

  final testPage = ReadingPage(
    id: '1',
    url: 'http://example.com/image.png',
    index: 0,
    metadata: const ImageMetadata(width: 100, height: 200),
  );

  group('ImageReaderItem', () {
    testWidgets('uses initial dimensions from page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(testPage));

      final aspectRatioFinder = find.byType(AspectRatio);
      final AspectRatio aspectRatioWidget = tester.widget(aspectRatioFinder);

      expect(aspectRatioWidget.aspectRatio, 0.5); // 100 / 200
    });

    testWidgets('uses cached dimensions if available', (
      WidgetTester tester,
    ) async {
      ImageAspectRatioCache.set(testPage.url, 1.5);

      await tester.pumpWidget(createWidget(testPage));

      final aspectRatioFinder = find.byType(AspectRatio);
      final AspectRatio aspectRatioWidget = tester.widget(aspectRatioFinder);

      expect(aspectRatioWidget.aspectRatio, 1.5);
    });

    testWidgets('updates aspect ratio and cache when image loads', (
      WidgetTester tester,
    ) async {
      // 1x1 transparent PNG
      final transparentPng = Uint8List.fromList([
        0x89,
        0x50,
        0x4E,
        0x47,
        0x0D,
        0x0A,
        0x1A,
        0x0A,
        0x00,
        0x00,
        0x00,
        0x0D,
        0x49,
        0x48,
        0x44,
        0x52,
        0x00,
        0x00,
        0x00,
        0x01,
        0x00,
        0x00,
        0x00,
        0x01,
        0x08,
        0x06,
        0x00,
        0x00,
        0x00,
        0x1F,
        0x15,
        0xC4,
        0x89,
        0x00,
        0x00,
        0x00,
        0x0A,
        0x49,
        0x44,
        0x41,
        0x54,
        0x78,
        0x9C,
        0x63,
        0x00,
        0x01,
        0x00,
        0x00,
        0x05,
        0x00,
        0x01,
        0x0D,
        0x0A,
        0x2D,
        0xB4,
        0x00,
        0x00,
        0x00,
        0x00,
        0x49,
        0x45,
        0x4E,
        0x44,
        0xAE,
        0x42,
        0x60,
        0x82,
      ]);

      when(
        () => mockDio.get<List<int>>(any(), options: any(named: 'options')),
      ).thenAnswer(
        (_) async => Response<List<int>>(
          data: transparentPng,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      await tester.pumpWidget(createWidget(testPage));

      // Initial aspect ratio from page (0.5)
      expect(
        (tester.widget(find.byType(AspectRatio)) as AspectRatio).aspectRatio,
        0.5,
      );

      await tester.pump(); // Start fetch
      await tester.pump(); // Finish fetch
      await tester.pump(); // Finish image frame build

      // Updated aspect ratio from 1x1 image (1.0)
      expect(
        (tester.widget(find.byType(AspectRatio)) as AspectRatio).aspectRatio,
        1.0,
      );
      expect(ImageAspectRatioCache.get(testPage.url), 1.0);
    });
  });
}
