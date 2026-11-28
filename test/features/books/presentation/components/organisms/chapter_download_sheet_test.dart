import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/presentation/components/organisms/chapter_download_sheet.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import 'package:gatuno/shared/components/atoms/app_outlined_button.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget sheet) => tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: sheet),
    ),
  );

  testWidgets('failed: reason, Try again and an outlined Delete', (
    tester,
  ) async {
    final calls = <String>[];
    await pump(
      tester,
      ChapterDownloadSheet.failed(
        title: 'Chapter 116 - Extra',
        reason: 'Not enough space.',
        onRetry: () => calls.add('retry'),
        onDelete: () => calls.add('delete'),
      ),
    );

    expect(find.text('Chapter 116 - Extra'), findsOneWidget);
    expect(find.text('The download failed'), findsOneWidget);
    expect(find.text('Not enough space.'), findsOneWidget);
    expect(
      tester
          .widget<AppOutlinedButton>(
            find.widgetWithText(AppOutlinedButton, 'Delete download'),
          )
          .tone,
      AppOutlinedButtonTone.danger,
    );

    await tester.tap(find.text('Try again'));
    await tester.tap(find.text('Delete download'));
    expect(calls, ['retry', 'delete']);
  });

  testWidgets('done: size and Delete, no retry', (tester) async {
    var deleted = false;
    await pump(
      tester,
      ChapterDownloadSheet.done(
        title: 'Chapter 115',
        size: '3 MB',
        onDelete: () => deleted = true,
      ),
    );

    expect(find.text('Downloaded · 3 MB'), findsOneWidget);
    expect(find.text('Try again'), findsNothing);

    await tester.tap(find.text('Delete download'));
    expect(deleted, isTrue);
  });
}
