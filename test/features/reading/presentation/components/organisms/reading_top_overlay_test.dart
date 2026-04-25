import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/reading/domain/entities/reading_chapter.dart';
import 'package:gatuno/features/reading/presentation/components/molecules/reading_top_bar.dart';
import 'package:gatuno/features/reading/presentation/components/organisms/reading_top_overlay.dart';
import '../../../../../helpers/pump_app.dart';

class _MockChapter extends Fake implements ReadingChapter {
  @override
  final String? title = 'Chapter 1';
  @override
  final String bookTitle = 'Test Book';
  @override
  final double index = 1.0;
}

void main() {
  group('ReadingTopOverlay', () {
    testWidgets('renders ReadingTopBar when showOverlay is true', (
      tester,
    ) async {
      await tester.pumpApp(
        Stack(
          children: [
            ReadingTopOverlay(showOverlay: true, chapter: _MockChapter()),
          ],
        ),
      );

      expect(find.byType(ReadingTopBar), findsOneWidget);
    });

    testWidgets('renders SizedBox.shrink when showOverlay is false', (
      tester,
    ) async {
      await tester.pumpApp(
        Stack(
          children: [
            ReadingTopOverlay(showOverlay: false, chapter: _MockChapter()),
          ],
        ),
      );

      expect(find.byType(ReadingTopBar), findsNothing);
    });
  });
}
