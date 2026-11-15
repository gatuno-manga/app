import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/theme.dart';
import 'package:gatuno/shared/components/atoms/app_text_button.dart';
import 'package:gatuno/shared/components/organisms/app_confirm_dialog.dart';

import '../../../helpers/pump_app.dart';

void main() {
  late bool? result;

  /// Pumps a page whose button opens the dialog and stores its result.
  Future<void> open(
    WidgetTester tester, {
    bool destructive = false,
    String? cancelLabel,
    Locale? locale,
  }) async {
    result = null;
    await tester.pumpApp(
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: AppTextButton(
              text: 'Open',
              onPressed: () async {
                result = await AppConfirmDialog.show(
                  context,
                  title: 'Delete it?',
                  body: 'It cannot be undone.',
                  confirmLabel: 'Delete',
                  cancelLabel: cancelLabel,
                  destructive: destructive,
                );
              },
            ),
          ),
        ),
      ),
      theme: AppTheme.darkTheme,
      locale: locale,
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  AppTextButton action(WidgetTester tester, String text) =>
      tester.widget<AppTextButton>(find.widgetWithText(AppTextButton, text));

  group('AppConfirmDialog', () {
    testWidgets('shows title, body and both actions', (tester) async {
      await open(tester);

      expect(find.text('Delete it?'), findsOneWidget);
      expect(find.text('It cannot be undone.'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('confirm resolves to true', (tester) async {
      await open(tester);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(find.byType(AppConfirmDialog), findsNothing);
    });

    testWidgets('cancel resolves to false', (tester) async {
      await open(tester);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets('tapping outside resolves to false', (tester) async {
      await open(tester);

      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();

      expect(find.byType(AppConfirmDialog), findsNothing);
      expect(result, isFalse);
    });

    testWidgets('back resolves to false', (tester) async {
      await open(tester);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(AppConfirmDialog), findsNothing);
      expect(result, isFalse);
    });

    testWidgets('a destructive confirm uses the danger tone', (tester) async {
      await open(tester, destructive: true);

      expect(action(tester, 'Delete').tone, AppTextButtonTone.danger);
      expect(action(tester, 'Cancel').tone, AppTextButtonTone.neutral);
    });

    testWidgets('a default confirm uses the primary tone', (tester) async {
      await open(tester);

      expect(action(tester, 'Delete').tone, AppTextButtonTone.primary);
    });

    testWidgets('takes a custom cancel label', (tester) async {
      await open(tester, cancelLabel: 'Keep it');

      expect(find.text('Keep it'), findsOneWidget);
      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('the default cancel label is localized', (tester) async {
      await open(tester, locale: const Locale('pt'));

      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('uses the context menu surface with a hairline border', (
      tester,
    ) async {
      await open(tester);

      final palette = AppTheme.darkTheme.extension<GatunoColors>()!.palette;
      final dialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
      expect(dialog.backgroundColor, palette.contextMenuBackground);
      expect(dialog.surfaceTintColor, Colors.transparent);
      final shape = dialog.shape! as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(16));
      expect(shape.side.color, palette.text10);
    });
  });
}
