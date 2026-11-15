import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gatuno/features/books/domain/entities/chapter.dart';
import 'package:gatuno/features/reading/domain/entities/reading_chapter.dart';
import 'package:gatuno/features/reading/presentation/components/templates/reading_template.dart';
import 'package:gatuno/shared/components/molecules/app_error_view.dart';
import 'package:gatuno/shared/components/molecules/app_offline_empty_view.dart';
import '../../../../../helpers/pump_app.dart';

class _MockChapter extends Fake implements ReadingChapter {
  @override
  ScrapingStatus? get scrapingStatus => null;
}

void main() {
  group('ReadingTemplate', () {
    testWidgets('renders loading indicator when isLoading is true', (
      tester,
    ) async {
      await tester.pumpApp(
        ReadingTemplate(
          isLoading: true,
          onOfflineRetry: () {},
          onRetry: () {},
          onGoBack: () {},
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
          onOfflineRetry: () {},
          onRetry: () {},
          onGoBack: () {},
          readerBuilder: (_) => const SizedBox(),
        ),
      );

      expect(find.byType(AppErrorView), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('renders readerBuilder when chapter is present', (
      tester,
    ) async {
      final chapter = _MockChapter();
      await tester.pumpApp(
        ReadingTemplate(
          isLoading: false,
          chapter: chapter,
          onOfflineRetry: () {},
          onRetry: () {},
          onGoBack: () {},
          readerBuilder: (chap) => const Text('Reader Content'),
        ),
      );

      expect(find.text('Reader Content'), findsOneWidget);
    });

    testWidgets('offline, an unsaved chapter shows the offline view', (
      tester,
    ) async {
      var retried = 0;
      var wentBack = 0;
      await tester.pumpApp(
        ReadingTemplate(
          isLoading: false,
          isOfflineMiss: true,
          onOfflineRetry: () => retried++,
          onRetry: () {},
          onGoBack: () => wentBack++,
          readerBuilder: (_) => const Text('Reader Content'),
        ),
      );

      expect(find.byType(AppOfflineEmptyView), findsOneWidget);
      expect(find.byType(AppErrorView), findsNothing);
      expect(find.text('Reader Content'), findsNothing);

      await tester.tap(find.text('Retry'));
      expect(retried, 1);

      await tester.tap(find.byTooltip('Go Back'));
      expect(wentBack, 1);
    });

    testWidgets('a failed offline retry is said under the offline view', (
      tester,
    ) async {
      await tester.pumpApp(
        ReadingTemplate(
          isLoading: false,
          isOfflineMiss: true,
          stillOffline: true,
          onOfflineRetry: () {},
          onRetry: () {},
          onGoBack: () {},
          readerBuilder: (_) => const SizedBox(),
        ),
      );

      expect(find.byType(AppOfflineEmptyView), findsOneWidget);
      final message = find.text('Still offline.');
      expect(message, findsOneWidget);
      expect(
        tester
            .widget<Semantics>(
              find
                  .ancestor(of: message, matching: find.byType(Semantics))
                  .first,
            )
            .properties
            .liveRegion,
        isTrue,
      );
    });
  });
}
