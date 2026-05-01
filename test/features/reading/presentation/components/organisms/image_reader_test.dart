import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/reading/domain/entities/reading_chapter.dart';
import 'package:gatuno/features/reading/presentation/components/organisms/image_reader.dart';
import 'package:gatuno/features/reading/presentation/components/organisms/reading_bottom_overlay.dart';
import 'package:gatuno/features/reading/presentation/components/organisms/reading_top_overlay.dart';
import 'package:gatuno/features/reading/presentation/view_models/reading_view_model.dart';
import 'package:gatuno/shared/domain/entities/image_metadata.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import '../../../../../helpers/pump_app.dart';
import '../../../../../helpers/test_injection.dart';

class MockReadingViewModel extends Mock implements ReadingViewModel {}

class _MockChapter extends Fake implements ReadingChapter {
  @override
  final String id = 'chapter-1';
  @override
  final List<ReadingPage> pages;
  @override
  final String? previous = null;
  @override
  final String? next = null;
  @override
  final String? title = 'Chapter 1';
  @override
  final String bookTitle = 'Test Book';
  @override
  final double index = 1.0;

  _MockChapter({required this.pages});
}

class _MockPage extends Fake implements ReadingPage {
  @override
  final String id;
  @override
  final String url;
  @override
  final int index;
  @override
  final ImageMetadata? metadata = const ImageMetadata(width: 100, height: 200);

  _MockPage({required this.id, required this.url, required this.index});

  @override
  double? get width => metadata?.width;
  @override
  double? get height => metadata?.height;
}

void main() {
  late MockReadingViewModel mockViewModel;

  setUp(() async {
    mockViewModel = MockReadingViewModel();
    when(() => mockViewModel.currentPageIndex).thenReturn(0);
    await initTestDI();
  });

  group('ImageReader', () {
    testWidgets('renders pages and toggles overlay on tap', (tester) async {
      final chapter = _MockChapter(
        pages: [
          _MockPage(id: '1', url: 'p1.png', index: 0),
          _MockPage(id: '2', url: 'p2.png', index: 1),
        ],
      );

      await tester.pumpApp(
        ChangeNotifierProvider<ReadingViewModel>.value(
          value: mockViewModel,
          child: Scaffold(body: ImageReader(chapter: chapter)),
        ),
      );

      // Verify readers are present
      expect(find.byType(ListView), findsOneWidget);

      // Overlays should be hidden initially
      final topOverlay = tester.widget<ReadingTopOverlay>(
        find.byType(ReadingTopOverlay),
      );
      final bottomOverlay = tester.widget<ReadingBottomOverlay>(
        find.byType(ReadingBottomOverlay),
      );
      expect(topOverlay.showOverlay, isFalse);
      expect(bottomOverlay.showOverlay, isFalse);

      // Tap to toggle overlay
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();

      // Overlays should now be shown
      final topOverlayShown = tester.widget<ReadingTopOverlay>(
        find.byType(ReadingTopOverlay),
      );
      final bottomOverlayShown = tester.widget<ReadingBottomOverlay>(
        find.byType(ReadingBottomOverlay),
      );
      expect(topOverlayShown.showOverlay, isTrue);
      expect(bottomOverlayShown.showOverlay, isTrue);
    });
  });
}
