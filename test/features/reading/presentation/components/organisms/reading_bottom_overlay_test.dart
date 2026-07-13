import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';


import 'package:gatuno/features/reading/domain/entities/reading_chapter.dart';
import 'package:gatuno/features/reading/presentation/components/molecules/reading_bottom_bar.dart';
import 'package:gatuno/features/reading/presentation/components/organisms/reading_bottom_overlay.dart';
import 'package:gatuno/features/reading/presentation/view_models/reading_view_model.dart';
import 'package:mocktail/mocktail.dart';


import 'package:provider/provider.dart';
import '../../../../../helpers/pump_app.dart';

class MockReadingViewModel extends Mock implements ReadingViewModel {}

class _MockChapter extends Fake implements ReadingChapter {
  @override
  final List<ReadingPage> pages = [];
  @override
  final ChapterId? previous = null;
  @override
  final ChapterId? next = null;
}

void main() {
  late MockReadingViewModel mockViewModel;

    setUpAll(() {
    registerFallbackValue(ChapterId('dummy'));
  });

setUp(() {
    mockViewModel = MockReadingViewModel();
    when(() => mockViewModel.state).thenReturn(ReadingState.initial());
    when(() => mockViewModel.stateStream).thenAnswer((_) => Stream.value(ReadingState.initial()));
    when(() => mockViewModel.currentPageIndex).thenReturn(0);
  });

  group('ReadingBottomOverlay', () {
    testWidgets('renders ReadingBottomBar when showOverlay is true', (
      tester,
    ) async {
      await tester.pumpApp(
        Provider<ReadingViewModel>.value(
          value: mockViewModel,
          child: Stack(
            children: [
              ReadingBottomOverlay(showOverlay: true, chapter: _MockChapter()),
            ],
          ),
        ),
      );

      expect(find.byType(ReadingBottomBar), findsOneWidget);
    });

    testWidgets('renders SizedBox.shrink when showOverlay is false', (
      tester,
    ) async {
      await tester.pumpApp(
        Provider<ReadingViewModel>.value(
          value: mockViewModel,
          child: Stack(
            children: [
              ReadingBottomOverlay(showOverlay: false, chapter: _MockChapter()),
            ],
          ),
        ),
      );

      expect(find.byType(ReadingBottomBar), findsNothing);
    });
  });
}
