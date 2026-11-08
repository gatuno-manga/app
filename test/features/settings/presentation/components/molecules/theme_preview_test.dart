import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/app_theme_choice.dart';
import 'package:gatuno/features/settings/presentation/components/atoms/palette_preview.dart';
import 'package:gatuno/features/settings/presentation/components/molecules/theme_preview.dart';

Widget _host(AppThemeChoice choice) => MaterialApp(
  home: Scaffold(body: ThemePreview(choice: choice)),
);

void main() {
  testWidgets('system shows the Light and Dark palettes side by side', (
    tester,
  ) async {
    await tester.pumpWidget(_host(AppThemeChoice.system));

    final palettes = tester
        .widgetList<PalettePreview>(find.byType(PalettePreview))
        .map((p) => p.palette)
        .toList();
    expect(palettes, [
      AppThemeChoice.light.palette,
      AppThemeChoice.dark.palette,
    ]);
  });

  testWidgets('a concrete theme shows only its own palette', (tester) async {
    await tester.pumpWidget(_host(AppThemeChoice.dracula));

    final preview = tester.widget<PalettePreview>(find.byType(PalettePreview));
    expect(preview.palette, AppThemeChoice.dracula.palette);
  });
}
