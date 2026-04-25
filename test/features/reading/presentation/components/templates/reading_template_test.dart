import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/reading/domain/entities/reading_chapter.dart';
import 'package:gatuno/features/reading/presentation/components/templates/reading_template.dart';
import 'package:gatuno/shared/components/molecules/app_error_view.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../../helpers/pump_app.dart';

class _MockChapter extends Fake implements ReadingChapter {}

void main() {
  group('ReadingTemplate', () {
    testWidgets('renders loading indicator when isLoading is true', (tester) async {
      await tester.pumpApp(
        ReadingTemplate(
          isLoading: true,
          onRetry: () {},
          readerBuilder: (_) => const SizedBox(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders AppErrorView when error is present', (tester) async {
      await tester.pumpApp(
        ReadingTemplate(
          isLoading: false,
          error: 'Something went wrong',
          onRetry: () {},
          readerBuilder: (_) => const SizedBox(),
        ),
      );

      expect(find.byType(AppErrorView), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('renders readerBuilder when chapter is present', (tester) async {
      final chapter = _MockChapter();
      await tester.pumpApp(
        ReadingTemplate(
          isLoading: false,
          chapter: chapter,
          onRetry: () {},
          readerBuilder: (chap) => const Text('Reader Content'),
        ),
      );

      expect(find.text('Reader Content'), findsOneWidget);
    });
  });
}
