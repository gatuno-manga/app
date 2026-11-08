import 'package:gatuno_lints/src/rules/raw_widget_outside_atoms.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'flutter_stub.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(RawWidgetOutsideAtomsTest);
    defineReflectiveTests(RawWidgetInAtomTest);
  });
}

@reflectiveTest
class RawWidgetOutsideAtomsTest extends FlutterRuleTest {
  @override
  void setUp() {
    rule = RawWidgetOutsideAtoms();
    super.setUp();
  }

  void test_elevated_button() async {
    const code = 'final w = ElevatedButton(child: Text("x"));';
    await assertDiagnostics('${FlutterRuleTest.import}$code', [
      lint(FlutterRuleTest.import.length + 10, 14),
    ]);
  }

  void test_text_field() async {
    const code = 'final w = TextField();';
    await assertDiagnostics('${FlutterRuleTest.import}$code', [
      lint(FlutterRuleTest.import.length + 10, 9),
    ]);
  }

  void test_named_constructor() async {
    const code = 'final w = IconButton.filled(icon: Icon(1));';
    await assertDiagnostics('${FlutterRuleTest.import}$code', [
      lint(FlutterRuleTest.import.length + 10, 17),
    ]);
  }

  void test_other_widgets_allowed() async {
    await assertNoDiagnostics(
      '${FlutterRuleTest.import}final w = SizedBox(child: Text("x"));',
    );
  }

  void test_app_widget_with_same_name_allowed() async {
    await assertNoDiagnostics('''
${FlutterRuleTest.import}
class TextField extends Widget { const TextField(); }
final w = TextField();
''');
  }
}

@reflectiveTest
class RawWidgetInAtomTest extends FlutterRuleTest {
  @override
  String get testFilePath =>
      '$testPackageLibPath/shared/components/atoms/$testFileName';

  @override
  void setUp() {
    rule = RawWidgetOutsideAtoms();
    super.setUp();
  }

  void test_atoms_may_build_raw_widgets() async {
    await assertNoDiagnostics(
      '${FlutterRuleTest.import}final w = TextField();',
    );
  }
}
