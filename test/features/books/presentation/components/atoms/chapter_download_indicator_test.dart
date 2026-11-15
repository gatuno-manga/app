import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/semantic_colors.dart';
import 'package:gatuno/core/theme/theme.dart';
import 'package:gatuno/features/books/presentation/components/atoms/chapter_download_indicator.dart';
import 'package:gatuno/features/books/presentation/models/download_display.dart';

void main() {
  final theme = AppTheme.lightTheme;

  Future<void> pump(
    WidgetTester tester,
    ChapterDownloadStatus status, {
    double progress = 0,
    VoidCallback? onTap,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Scaffold(
        body: Center(
          child: ChapterDownloadIndicator(
            status: status,
            progress: progress,
            semanticLabel: 'label',
            onTap: onTap,
          ),
        ),
      ),
    ),
  );

  Icon iconOf(WidgetTester tester, IconData icon) =>
      tester.widget<Icon>(find.byIcon(icon));

  final glyphs = {
    ChapterDownloadStatus.none: (
      Icons.download,
      theme.legible(theme.mutedColor),
    ),
    ChapterDownloadStatus.queued: (
      Icons.schedule,
      theme.legible(theme.warningColor),
    ),
    ChapterDownloadStatus.waitingForNetwork: (
      Icons.wifi,
      theme.legible(theme.warningColor),
    ),
    ChapterDownloadStatus.waitingForConnection: (
      Icons.cloud_off,
      theme.legible(theme.warningColor),
    ),
    ChapterDownloadStatus.failed: (
      Icons.error_outline,
      theme.legible(theme.colorScheme.error),
    ),
    ChapterDownloadStatus.done: (
      Icons.check,
      theme.legible(theme.successColor),
    ),
  };

  for (final MapEntry(key: status, value: (icon, color)) in glyphs.entries) {
    testWidgets('$status draws its legible glyph', (tester) async {
      await pump(tester, status);

      expect(iconOf(tester, icon).color, color);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  }

  testWidgets('running draws a primary ring with its progress and pause', (
    tester,
  ) async {
    await pump(tester, ChapterDownloadStatus.running, progress: 0.25);

    final ring = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    expect(ring.value, 0.25);
    expect(ring.color, theme.colorScheme.primary);
    expect(find.byIcon(Icons.pause), findsOneWidget);
  });

  testWidgets('paused draws a muted ring with play', (tester) async {
    await pump(tester, ChapterDownloadStatus.paused, progress: 0.5);

    final ring = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    expect(ring.color, theme.legible(theme.mutedColor));
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });

  testWidgets('a 48 dp target that reports taps', (tester) async {
    var taps = 0;
    await pump(tester, ChapterDownloadStatus.none, onTap: () => taps++);

    expect(
      tester.getSize(find.byType(ChapterDownloadIndicator)),
      const Size(48, 48),
    );
    await tester.tap(find.byType(ChapterDownloadIndicator));
    expect(taps, 1);
  });

  testWidgets('announces its label, as a button only when tappable', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(tester, ChapterDownloadStatus.done, onTap: () {});
    expect(
      tester.getSemantics(find.byType(ChapterDownloadIndicator)),
      matchesSemantics(
        label: 'label',
        isButton: true,
        hasTapAction: true,
        isFocusable: true,
        hasFocusAction: true,
      ),
    );

    await pump(tester, ChapterDownloadStatus.done);
    expect(
      tester.getSemantics(find.byType(ChapterDownloadIndicator)),
      matchesSemantics(label: 'label'),
    );
    handle.dispose();
  });
}
