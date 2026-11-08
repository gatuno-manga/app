import 'package:gatuno_lints/src/rules/hardcoded_color.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'flutter_stub.dart';

void main() {
  defineReflectiveSuite(() => defineReflectiveTests(HardcodedColorTest));
}

@reflectiveTest
class HardcodedColorTest extends FlutterRuleTest {
  @override
  void setUp() {
    rule = HardcodedColor();
    super.setUp();
  }

  void test_colors_constant() async {
    await assertDiagnostics('${FlutterRuleTest.import}const c = Colors.red;', [
      lint(FlutterRuleTest.import.length + 10, 10),
    ]);
  }

  void test_color_literal() async {
    await assertDiagnostics(
      '${FlutterRuleTest.import}const c = Color(0xFF000000);',
      [lint(FlutterRuleTest.import.length + 10, 17)],
    );
  }

  void test_color_from_argb() async {
    await assertDiagnostics(
      '${FlutterRuleTest.import}const c = Color.fromARGB(1, 2, 3, 4);',
      [lint(FlutterRuleTest.import.length + 10, 26)],
    );
  }

  void test_computed_color_is_data() async {
    await assertNoDiagnostics('''
${FlutterRuleTest.import}
Color f(int v) => Color(v);
''');
  }

  void test_transparent_allowed() async {
    await assertNoDiagnostics(
      '${FlutterRuleTest.import}const c = Colors.transparent;',
    );
  }

  void test_theme_layer_exempt() async {
    final file = newFile(
      '$testPackageLibPath/core/theme/palette.dart',
      '${FlutterRuleTest.import}const c = Colors.red;',
    );
    await assertNoDiagnosticsInFile(file.path);
  }

  void test_non_flutter_colors_ignored() async {
    await assertNoDiagnostics('''
class Colors { static const red = 1; }
final c = Colors.red;
''');
  }
}
