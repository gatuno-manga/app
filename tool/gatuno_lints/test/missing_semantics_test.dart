import 'package:gatuno_lints/src/rules/missing_semantics.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'flutter_stub.dart';

void main() {
  defineReflectiveSuite(() => defineReflectiveTests(MissingSemanticsTest));
}

@reflectiveTest
class MissingSemanticsTest extends FlutterRuleTest {
  @override
  void setUp() {
    rule = MissingSemantics();
    super.setUp();
  }

  void test_bare_icon_tap() async {
    const code = 'final w = GestureDetector(child: Icon(1));';
    await assertDiagnostics('${FlutterRuleTest.import}$code', [
      lint(FlutterRuleTest.import.length + 10, 15),
    ]);
  }

  void test_bare_inkwell() async {
    await assertDiagnostics('${FlutterRuleTest.import}final w = InkWell();', [
      lint(FlutterRuleTest.import.length + 10, 7),
    ]);
  }

  void test_wrapped_in_semantics() async {
    await assertNoDiagnostics(
      '${FlutterRuleTest.import}'
      "final w = Semantics(label: 'x', child: GestureDetector());",
    );
  }

  void test_labelled_child() async {
    await assertNoDiagnostics(
      '${FlutterRuleTest.import}'
      "final w = InkWell(child: Text('x'));",
    );
  }

  void test_icon_with_semantic_label() async {
    await assertNoDiagnostics(
      '${FlutterRuleTest.import}'
      "final w = InkWell(child: Icon(1, semanticLabel: 'x'));",
    );
  }

  void test_app_widget_child_is_not_inspected() async {
    await assertNoDiagnostics('''
${FlutterRuleTest.import}
class Card2 extends Widget { const Card2(); }
final w = InkWell(child: Card2());
''');
  }

  void test_child_built_elsewhere_is_not_inspected() async {
    await assertNoDiagnostics('''
${FlutterRuleTest.import}
Widget f(Widget child) => GestureDetector(child: child);
''');
  }
}
