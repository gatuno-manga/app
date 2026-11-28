import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/app_palette.dart';
import 'package:gatuno/shared/components/atoms/app_skeleton.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) =>
      tester.pumpWidget(MaterialApp(home: Center(child: child)));

  BoxDecoration decorationOf(WidgetTester tester) {
    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(AppSkeleton),
        matching: find.byType(Container),
      ),
    );
    return container.decoration! as BoxDecoration;
  }

  testWidgets('fills with color/text-10 and radius/sm', (tester) async {
    await pump(tester, const AppSkeleton.block(width: 40, height: 20));

    final decoration = decorationOf(tester);
    expect(decoration.color, lightPalette.text10);
    expect(decoration.borderRadius, BorderRadius.circular(4));
  });

  testWidgets('block has the given size and no margin', (tester) async {
    await pump(tester, const AppSkeleton.block(width: 40, height: 20));

    expect(tester.getSize(find.byType(AppSkeleton)), const Size(40, 20));
  });

  testWidgets('text line defaults to 160x16 with a 4 dp vertical margin', (
    tester,
  ) async {
    await pump(tester, const AppSkeleton.textLine());

    expect(tester.getSize(find.byType(AppSkeleton)), const Size(160, 24));
  });

  testWidgets('text line takes its width and height from the caller', (
    tester,
  ) async {
    await pump(tester, const AppSkeleton.textLine(width: 120, height: 24));

    expect(tester.getSize(find.byType(AppSkeleton)), const Size(120, 32));
  });
}
