import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/app_palette.dart';
import 'package:gatuno/core/theme/semantic_colors.dart';
import 'package:gatuno/core/theme/theme.dart';
import 'package:gatuno/features/books/presentation/components/molecules/book_downloads_summary.dart';

void main() {
  final theme = AppTheme.darkTheme;

  Future<void> pump(WidgetTester tester, BookDownloadsSummary summary) =>
      tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(body: summary),
        ),
      );

  testWidgets('shows the count, status, action and bar', (tester) async {
    var taps = 0;
    await pump(
      tester,
      BookDownloadsSummary(
        countLabel: '12 of 120 chapters downloaded · 412 MB',
        statusLabel: 'Downloading 3 chapters',
        actionLabel: 'Pause all',
        onAction: () => taps++,
        progress: 0.4,
      ),
    );

    expect(find.text('12 of 120 chapters downloaded · 412 MB'), findsOneWidget);
    expect(find.text('Downloading 3 chapters'), findsOneWidget);
    final bar = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(bar.value, 0.4);
    expect(bar.color, theme.colorScheme.primary);

    await tester.tap(find.text('Pause all'));
    expect(taps, 1);
  });

  testWidgets('waiting for the server mutes the bar', (tester) async {
    await pump(
      tester,
      const BookDownloadsSummary(
        countLabel: 'count',
        progress: 0.4,
        progressMuted: true,
      ),
    );

    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .color,
      darkPalette.textSecondary,
    );
  });

  testWidgets('a failure status is legible danger; no bar, no action', (
    tester,
  ) async {
    await pump(
      tester,
      const BookDownloadsSummary(
        countLabel: 'count',
        statusLabel: '2 chapters failed',
        statusIsError: true,
      ),
    );

    expect(
      tester.widget<Text>(find.text('2 chapters failed')).style?.color,
      theme.legible(theme.colorScheme.error),
    );
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byType(TextButton), findsNothing);
  });
}
