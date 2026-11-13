import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/reader_palette.dart';
import 'package:gatuno/core/theme/theme.dart';
import 'package:gatuno/features/reading/domain/entities/reader_preferences.dart';
import 'package:gatuno/features/reading/presentation/components/molecules/reading_ruler.dart';
import 'package:gatuno/features/reading/presentation/theme/reader_theme_scope.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  late ReaderPalette palette;

  Future<void> pump(WidgetTester tester, {required VoidCallback onTapBelow}) =>
      tester.pumpApp(
        ReaderThemeScope(
          theme: ReaderTheme.cream,
          child: Builder(
            builder: (context) {
              palette = Theme.of(context).extension<ReaderPalette>()!;
              return SizedBox(
                height: 400,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: onTapBelow,
                        behavior: HitTestBehavior.opaque,
                      ),
                    ),
                    Positioned.fill(
                      child: ReadingRuler(palette: palette, lineHeight: 40),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        theme: AppTheme.lightTheme,
      );

  final band = find.byWidgetPredicate(
    (w) =>
        w is DecoratedBox &&
        w.decoration is BoxDecoration &&
        (w.decoration as BoxDecoration).border is Border,
  );

  double rulerTop(WidgetTester tester) =>
      tester.getTopLeft(find.byType(ReadingRuler)).dy;

  testWidgets('starts centred and one line tall', (tester) async {
    await pump(tester, onTapBelow: () {});

    final rect = tester.getRect(band);
    expect(rect.height, 40);
    expect(
      rect.center.dy - rulerTop(tester),
      closeTo(tester.getSize(find.byType(ReadingRuler)).height / 2, 1),
    );
  });

  testWidgets('dragging the band moves it and clamps at the edges', (
    tester,
  ) async {
    await pump(tester, onTapBelow: () {});

    final start = tester.getRect(band).top;
    // The first ~20 dp of a drag are touch slop and do not count.
    await tester.drag(band, const Offset(0, 100));
    await tester.pump();
    expect(tester.getRect(band).top, greaterThan(start + 40));

    await tester.drag(band, const Offset(0, 2000));
    await tester.pump();
    expect(
      tester.getRect(band).bottom,
      closeTo(tester.getRect(find.byType(ReadingRuler)).bottom, 1),
    );

    await tester.drag(band, const Offset(0, -2000));
    await tester.pump();
    expect(
      tester.getRect(band).top,
      closeTo(tester.getRect(find.byType(ReadingRuler)).top, 1),
    );
  });

  testWidgets('touches outside the band reach the content below', (
    tester,
  ) async {
    var taps = 0;
    await pump(tester, onTapBelow: () => taps++);

    await tester.tapAt(
      tester.getTopLeft(find.byType(ReadingRuler)) + const Offset(50, 10),
    );

    expect(taps, 1);
  });

  testWidgets('exposes move actions to assistive technology', (tester) async {
    await pump(tester, onTapBelow: () {});
    final handle = tester.ensureSemantics();

    final before = tester.getRect(band).top;
    tester.semantics.increase(find.semantics.byLabel(RegExp('Reading ruler')));
    await tester.pump();

    expect(tester.getRect(band).top, closeTo(before + 40, 1));
    handle.dispose();
  });
}
