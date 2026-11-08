import 'package:gatuno_lints/src/rules/small_tap_target.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'flutter_stub.dart';

void main() {
  defineReflectiveSuite(() => defineReflectiveTests(SmallTapTargetTest));
}

@reflectiveTest
class SmallTapTargetTest extends FlutterRuleTest {
  @override
  void setUp() {
    rule = SmallTapTarget();
    super.setUp();
  }

  void test_small_sized_box_around_tappable() async {
    const code = 'final w = SizedBox(width: 24, child: InkWell());';
    await assertDiagnostics('${FlutterRuleTest.import}$code', [
      lint(FlutterRuleTest.import.length + 10, 37),
    ]);
  }

  void test_small_height() async {
    const code = 'final w = SizedBox(height: 40, child: GestureDetector());';
    await assertDiagnostics('${FlutterRuleTest.import}$code', [
      lint(FlutterRuleTest.import.length + 10, 46),
    ]);
  }

  void test_48_is_enough() async {
    await assertNoDiagnostics(
      '${FlutterRuleTest.import}'
      'final w = SizedBox(width: 48, height: 48, child: InkWell());',
    );
  }

  void test_small_sized_box_around_non_tappable() async {
    await assertNoDiagnostics(
      '${FlutterRuleTest.import}'
      "final w = SizedBox(width: 16, child: Text('x'));",
    );
  }

  void test_shrink_wrap_button() async {
    const code =
        'final w = TextButton(materialTapTargetSize: '
        'MaterialTapTargetSize.shrinkWrap);';
    await assertDiagnostics('${FlutterRuleTest.import}$code', [
      lint(FlutterRuleTest.import.length + 44, 32),
    ]);
  }

  void test_computed_size_not_checked() async {
    await assertNoDiagnostics('''
${FlutterRuleTest.import}
Widget f(double size) => SizedBox(width: size, child: InkWell());
''');
  }

  void test_small_square() async {
    const code = 'final w = SizedBox.square(dimension: 32, child: InkWell());';
    await assertDiagnostics('${FlutterRuleTest.import}$code', [
      lint(FlutterRuleTest.import.length + 10, 48),
    ]);
  }
}
