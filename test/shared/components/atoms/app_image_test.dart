import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/image/image_loading_strategy.dart';
import 'package:gatuno/shared/components/atoms/app_image.dart';
import 'package:gatuno/shared/components/atoms/app_skeleton.dart';
import 'package:mocktail/mocktail.dart';
import '../../../helpers/test_injection.dart';

class MockImageLoadingStrategy extends Mock implements ImageLoadingStrategy {}

void main() {
  late MockImageLoadingStrategy mockStrategy;

  setUp(() async {
    mockStrategy = MockImageLoadingStrategy();
    await initTestDI();
  });

  Widget createWidget(String url, {ImageLoadingStrategy? strategy}) {
    return MaterialApp(
      home: Scaffold(
        body: AppImage(imageUrl: url, strategy: strategy ?? mockStrategy),
      ),
    );
  }

  group('AppImage', () {
    testWidgets('shows loading indicator while fetching', (
      WidgetTester tester,
    ) async {
      when(
        () => mockStrategy.loadImage(
          any(),
          onImageLoaded: any(named: 'onImageLoaded'),
        ),
      ).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        return Uint8List.fromList([1, 2, 3]);
      });

      await tester.pumpWidget(createWidget('http://example.com/image.png'));

      expect(find.byType(AppSkeleton), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('shows blurHash while loading when provided', (
      WidgetTester tester,
    ) async {
      when(
        () => mockStrategy.loadImage(
          any(),
          onImageLoaded: any(named: 'onImageLoaded'),
        ),
      ).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        return Uint8List.fromList([1, 2, 3]);
      });

      const blurHash = 'LEHV6nWB2yk8pyo0adR*.7kCMdnj';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppImage(
              imageUrl: 'http://example.com/image.png',
              strategy: mockStrategy,
              blurHash: blurHash,
            ),
          ),
        ),
      );

      expect(find.byType(BlurHash), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('shows error widget when fetch fails', (
      WidgetTester tester,
    ) async {
      when(
        () => mockStrategy.loadImage(
          any(),
          onImageLoaded: any(named: 'onImageLoaded'),
        ),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(createWidget('http://example.com/image.png'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.broken_image), findsOneWidget);
    });

    testWidgets('shows errorWidget instead of placeholder when fetch fails', (
      WidgetTester tester,
    ) async {
      when(
        () => mockStrategy.loadImage(
          any(),
          onImageLoaded: any(named: 'onImageLoaded'),
        ),
      ).thenAnswer((_) async => null);

      const placeholderKey = Key('placeholder');
      const errorKey = Key('error');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppImage(
              imageUrl: 'http://example.com/image.png',
              strategy: mockStrategy,
              placeholder: const SizedBox(key: placeholderKey),
              errorWidget: const SizedBox(key: errorKey),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(errorKey), findsOneWidget);
      expect(find.byKey(placeholderKey), findsNothing);
    });

    testWidgets('renders Image.memory when fetch is successful', (
      WidgetTester tester,
    ) async {
      // Smallest valid 1x1 transparent PNG
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
        () => mockStrategy.loadImage(
          any(),
          onImageLoaded: any(named: 'onImageLoaded'),
        ),
      ).thenAnswer((_) async => transparentPng);

      await tester.pumpWidget(createWidget('http://example.com/image.png'));
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('calls onImageLoaded with correct dimensions', (
      WidgetTester tester,
    ) async {
      when(
        () => mockStrategy.loadImage(
          any(),
          onImageLoaded: any(named: 'onImageLoaded'),
        ),
      ).thenAnswer((invocation) async {
        final onImageLoaded =
            invocation.namedArguments[#onImageLoaded] as void Function(Size)?;
        onImageLoaded?.call(const Size(1.0, 1.0));
        return Uint8List(0);
      });

      Size? loadedSize;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppImage(
              imageUrl: 'http://example.com/image.png',
              strategy: mockStrategy,
              onImageLoaded: (size) => loadedSize = size,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(loadedSize, isNotNull);
      expect(loadedSize!.width, 1.0);
      expect(loadedSize!.height, 1.0);
    });

    group('AppImage didUpdateWidget', () {
      testWidgets('refetches when imageUrl changes', (
        WidgetTester tester,
      ) async {
        when(
          () => mockStrategy.loadImage(
            any(),
            onImageLoaded: any(named: 'onImageLoaded'),
          ),
        ).thenAnswer((_) async => Uint8List(0));

        await tester.pumpWidget(createWidget('http://example.com/image1.png'));
        await tester.pumpAndSettle();

        verify(
          () => mockStrategy.loadImage(
            'http://example.com/image1.png',
            onImageLoaded: any(named: 'onImageLoaded'),
          ),
        ).called(1);

        await tester.pumpWidget(createWidget('http://example.com/image2.png'));
        await tester.pump();

        verify(
          () => mockStrategy.loadImage(
            'http://example.com/image2.png',
            onImageLoaded: any(named: 'onImageLoaded'),
          ),
        ).called(1);
      });

      testWidgets('refetches when strategy changes', (
        WidgetTester tester,
      ) async {
        final strategy1 = MockImageLoadingStrategy();
        final strategy2 = MockImageLoadingStrategy();

        when(
          () => strategy1.loadImage(
            any(),
            onImageLoaded: any(named: 'onImageLoaded'),
          ),
        ).thenAnswer((_) async => Uint8List(0));
        when(
          () => strategy2.loadImage(
            any(),
            onImageLoaded: any(named: 'onImageLoaded'),
          ),
        ).thenAnswer((_) async => Uint8List(0));

        await tester.pumpWidget(
          createWidget('http://example.com/image.png', strategy: strategy1),
        );
        await tester.pumpAndSettle();

        verify(
          () => strategy1.loadImage(
            'http://example.com/image.png',
            onImageLoaded: any(named: 'onImageLoaded'),
          ),
        ).called(1);

        await tester.pumpWidget(
          createWidget('http://example.com/image.png', strategy: strategy2),
        );
        await tester.pump();

        verify(
          () => strategy2.loadImage(
            'http://example.com/image.png',
            onImageLoaded: any(named: 'onImageLoaded'),
          ),
        ).called(1);
      });
    });
  });
}
