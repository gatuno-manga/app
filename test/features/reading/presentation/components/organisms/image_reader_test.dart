import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_title.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_index.dart';
import 'package:gatuno/shared/domain/value_objects/positive_int.dart';
import 'package:gatuno/features/reading/domain/value_objects/reading_page_id.dart';
import 'package:gatuno/features/reading/domain/value_objects/reading_page_url.dart';


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
  final ChapterId id = const ChapterId('chapter-1');
  @override
  final List<ReadingPage> pages;
  @override
  final ChapterId? previous = null;
  @override
  final ChapterId? next = null;
  @override
  final ChapterTitle? title = const ChapterTitle('Chapter 1');
  @override
  final BookTitle bookTitle = const BookTitle('Test Book');
  @override
  final ChapterIndex index = const ChapterIndex(1.0);

  _MockChapter({required this.pages});
}

class _MockPage extends Fake implements ReadingPage {
  @override
  final ReadingPageId id;
  @override
  final ReadingPageUrl url;
  @override
  final PositiveInt index;
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
    when(() => mockViewModel.state).thenReturn(ReadingState.initial());
    when(() => mockViewModel.stateStream).thenAnswer((_) => Stream.value(ReadingState.initial()));
    when(() => mockViewModel.currentPageIndex).thenReturn(0);
    await initTestDI();
  });

    setUpAll(() {
    registerFallbackValue(ChapterId('dummy'));
  });

group('ImageReader', () {
    testWidgets('renders pages and toggles overlay on tap', (tester) async {
      final chapter = _MockChapter(
        pages: [
          _MockPage(id: const ReadingPageId('1'), url: const ReadingPageUrl('p1.png'), index: const PositiveInt(0)),
          _MockPage(id: const ReadingPageId('2'), url: const ReadingPageUrl('p2.png'), index: const PositiveInt(1)),
        ],
      );

      await tester.pumpApp(
        Provider<ReadingViewModel>.value(
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
