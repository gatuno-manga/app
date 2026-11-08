import 'package:gatuno_lints/src/rules/inline_text_style.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'flutter_stub.dart';

void main() {
  defineReflectiveSuite(() => defineReflectiveTests(InlineTextStyleTest));
}

@reflectiveTest
class InlineTextStyleTest extends FlutterRuleTest {
  @override
  void setUp() {
    rule = InlineTextStyle();
    super.setUp();
  }

  void test_font_size() async {
    await assertDiagnostics(
      '${FlutterRuleTest.import}final s = TextStyle(fontSize: 16);',
      [lint(FlutterRuleTest.import.length + 10, 23)],
    );
  }

  void test_font_weight() async {
    await assertDiagnostics(
      '${FlutterRuleTest.import}final s = TextStyle(fontWeight: FontWeight.bold);',
      [lint(FlutterRuleTest.import.length + 10, 38)],
    );
  }

  void test_color_only_allowed() async {
    await assertNoDiagnostics(
      '${FlutterRuleTest.import}final s = TextStyle(color: null);',
    );
  }

  void test_theme_layer_exempt() async {
    final file = newFile(
      '$testPackageLibPath/core/theme/type.dart',
      '${FlutterRuleTest.import}final s = TextStyle(fontSize: 16);',
    );
    await assertNoDiagnosticsInFile(file.path);
  }
}
