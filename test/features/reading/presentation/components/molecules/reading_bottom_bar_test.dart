import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/reading/domain/entities/reading_chapter.dart';
import 'package:gatuno/features/reading/presentation/components/molecules/reading_bottom_bar.dart';
import 'package:gatuno/features/reading/presentation/view_models/reading_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import '../../../../../helpers/pump_app.dart';

class MockReadingViewModel extends Mock implements ReadingViewModel {}

class _MockChapter extends Fake implements ReadingChapter {
  @override
  final List<ReadingPage> pages;
  @override
  final String? previous;
  @override
  final String? next;

  _MockChapter({required this.pages, this.previous, this.next});
}

class FakeReadingPage extends Fake implements ReadingPage {}

void main() {
  late MockReadingViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockReadingViewModel();
    when(() => mockViewModel.currentPageIndex).thenReturn(0);
  });

  group('ReadingBottomBar', () {
    testWidgets('renders page indicator and navigation buttons', (tester) async {
      final chapter = _MockChapter(
        pages: [FakeReadingPage(), FakeReadingPage()],
        previous: 'prev-id',
        next: 'next-id',
      );

      await tester.pumpApp(
        ChangeNotifierProvider<ReadingViewModel>.value(
          value: mockViewModel,
          child: Scaffold(
            body: ReadingBottomBar(
              chapter: chapter,
              bottomPadding: 20.0,
            ),
          ),
        ),
      );

      expect(find.text('Page 1 of 2'), findsOneWidget);
      expect(find.byIcon(Icons.skip_previous), findsOneWidget);
      expect(find.byIcon(Icons.skip_next), findsOneWidget);
    });

    testWidgets('disables previous button when no previous chapter', (tester) async {
      final chapter = _MockChapter(pages: [], previous: null);

      await tester.pumpApp(
        ChangeNotifierProvider<ReadingViewModel>.value(
          value: mockViewModel,
          child: Scaffold(
            body: ReadingBottomBar(
              chapter: chapter,
              bottomPadding: 0.0,
            ),
          ),
        ),
      );

      final prevButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.skip_previous),
      );
      expect(prevButton.onPressed, isNull);
    });

    testWidgets('disables next button when no next chapter', (tester) async {
      final chapter = _MockChapter(pages: [], next: null);

      await tester.pumpApp(
        ChangeNotifierProvider<ReadingViewModel>.value(
          value: mockViewModel,
          child: Scaffold(
            body: ReadingBottomBar(
              chapter: chapter,
              bottomPadding: 0.0,
            ),
          ),
        ),
      );

      final nextButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.skip_next),
      );
      expect(nextButton.onPressed, isNull);
    });
  });
}
