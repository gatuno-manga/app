import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/theme.dart';
import 'package:gatuno/features/books/presentation/components/molecules/books_search_field.dart';
import 'package:gatuno/l10n/app_localizations.dart';

Future<TextEditingController> _pump(
  WidgetTester tester,
  ThemeData theme,
) async {
  final controller = TextEditingController();
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: BooksSearchField(controller: controller, onChanged: (_) {}),
        ),
      ),
    ),
  );
  return controller;
}

InputDecoration _decoration(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).decoration!;

void main() {
  final themes = {'dark': AppTheme.darkTheme, 'light': AppTheme.lightTheme};

  for (final entry in themes.entries) {
    group('search row spec (${entry.key})', () {
      testWidgets('is 48 dp high with radius 12, a 1 dp border and the fill', (
        tester,
      ) async {
        await _pump(tester, entry.value);
        final palette = entry.value.extension<GatunoColors>()!.palette;
        final decoration = _decoration(tester);

        expect(tester.getSize(find.byType(TextField)).height, 48);
        expect(decoration.filled, isTrue);
        expect(decoration.fillColor, palette.secondary60);
        final border = decoration.enabledBorder! as OutlineInputBorder;
        expect(border.borderRadius, BorderRadius.circular(12));
        expect(border.borderSide.width, 1);
        expect(border.borderSide.color, palette.border);
        final focused = decoration.focusedBorder! as OutlineInputBorder;
        expect(focused.borderSide.color, entry.value.colorScheme.primary);
        expect(tester.getSize(find.byType(TextField)).height, 48);
      });

      testWidgets('draws a 20 dp search icon 12 dp from the edge', (
        tester,
      ) async {
        await _pump(tester, entry.value);
        final icon = find.byIcon(Icons.search);

        expect(tester.getSize(icon), const Size(20, 20));
        final gap =
            tester.getTopLeft(icon).dx -
            tester.getTopLeft(find.byType(TextField)).dx;
        expect(gap, 12);
      });

      testWidgets('uses Corpo/Pequeno for the text and a muted hint', (
        tester,
      ) async {
        await _pump(tester, entry.value);
        final palette = entry.value.extension<GatunoColors>()!.palette;
        final field = tester.widget<TextField>(find.byType(TextField));

        expect(field.style?.fontSize, 14);
        expect(field.style?.height, 1.5);
        expect(field.decoration!.hintStyle?.fontSize, 14);
        expect(field.decoration!.hintStyle?.color, palette.textSecondary);
      });
    });
  }

  testWidgets('shows the clear button only while there is text', (
    tester,
  ) async {
    final controller = await _pump(tester, AppTheme.darkTheme);
    expect(find.byIcon(Icons.clear), findsNothing);

    controller.text = 'neon';
    await tester.pump();
    expect(find.byIcon(Icons.clear), findsOneWidget);
    expect(find.byTooltip('Clear search'), findsOneWidget);
    expect(tester.getSize(find.byType(TextField)).height, 48);

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();
    expect(controller.text, isEmpty);
    expect(find.byIcon(Icons.clear), findsNothing);
  });
}
