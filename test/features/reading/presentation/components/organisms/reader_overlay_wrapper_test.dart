import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/reading/domain/entities/reading_chapter.dart';
import 'package:gatuno/features/reading/presentation/components/organisms/reader_overlay_wrapper.dart';
import 'package:gatuno/features/reading/presentation/components/organisms/reading_bottom_overlay.dart';
import 'package:gatuno/features/reading/presentation/components/organisms/reading_top_overlay.dart';
import 'package:gatuno/features/reading/presentation/view_models/reading_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import '../../../../../helpers/pump_app.dart';

class MockReadingViewModel extends Mock implements ReadingViewModel {}

class _MockChapter extends Fake implements ReadingChapter {
  @override
  final String id = 'chapter-1';
  @override
  final String bookTitle = 'Test Book';
  @override
  final String? title = 'Test Chapter';
  @override
  final String? previous = null;
  @override
  final String? next = null;
  @override
  final List<ReadingPage> pages = [];
}

void main() {
  late MockReadingViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockReadingViewModel();
    when(() => mockViewModel.currentPageIndex).thenReturn(0);
  });

  testWidgets('ReaderOverlayWrapper toggles overlays on tap', (tester) async {
    final chapter = _MockChapter();

    await tester.pumpApp(
      ChangeNotifierProvider<ReadingViewModel>.value(
        value: mockViewModel,
        child: Scaffold(
          body: ReaderOverlayWrapper(
            chapter: chapter,
            child: const Center(child: Text('Content')),
          ),
        ),
      ),
    );

    // Initial state: overlays should be hidden (based on showOverlay property)
    // We can check if the Positioned widgets are effectively "hidden" or if their
    // internal AnimatedSwitcher has the correct child.
    // ReadingTopOverlay and ReadingBottomOverlay use showOverlay to decide what to show.

    final topOverlayFinder = find.byType(ReadingTopOverlay);
    final bottomOverlayFinder = find.byType(ReadingBottomOverlay);

    expect(topOverlayFinder, findsOneWidget);
    expect(bottomOverlayFinder, findsOneWidget);

    bool getShowOverlay(Finder finder) {
      final widget = tester.widget(finder);
      if (widget is ReadingTopOverlay) return widget.showOverlay;
      if (widget is ReadingBottomOverlay) return widget.showOverlay;
      return false;
    }

    expect(getShowOverlay(topOverlayFinder), isFalse);
    expect(getShowOverlay(bottomOverlayFinder), isFalse);

    // Tap to show overlays
    await tester.tap(find.text('Content'));
    await tester.pumpAndSettle();

    expect(getShowOverlay(topOverlayFinder), isTrue);
    expect(getShowOverlay(bottomOverlayFinder), isTrue);

    // Tap again to hide overlays
    await tester.tap(find.text('Content'));
    await tester.pumpAndSettle();

    expect(getShowOverlay(topOverlayFinder), isFalse);
    expect(getShowOverlay(bottomOverlayFinder), isFalse);
  });
}
