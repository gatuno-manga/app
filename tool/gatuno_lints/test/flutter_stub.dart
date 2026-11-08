import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';

/// Minimal `package:flutter` so rule tests resolve Flutter types.
abstract class FlutterRuleTest extends AnalysisRuleTest {
  static const _stub = r'''
class Color {
  const Color(int value);
  const Color.fromARGB(int a, int r, int g, int b);
  Color withValues({double? alpha}) => this;
}
class Colors {
  static const Color transparent = Color(0);
  static const Color red = Color(1);
  static const Color white = Color(2);
}
class FontWeight {
  static const FontWeight bold = FontWeight();
  const FontWeight();
}
class TextStyle {
  const TextStyle({Color? color, double? fontSize, String? fontFamily,
      FontWeight? fontWeight});
}
class Widget { const Widget(); }
class Text extends Widget { const Text(String data); }
class Icon extends Widget { const Icon(int icon, {String? semanticLabel}); }
class Semantics extends Widget {
  const Semantics({String? label, Widget? child});
}
class Tooltip extends Widget {
  const Tooltip({String? message, Widget? child});
}
class SizedBox extends Widget {
  const SizedBox({double? width, double? height, Widget? child});
  const SizedBox.square({double? dimension, Widget? child});
}
class InkWell extends Widget {
  const InkWell({Widget? child, void Function()? onTap});
}
class GestureDetector extends Widget {
  const GestureDetector({Widget? child, void Function()? onTap});
}
class ElevatedButton extends Widget {
  const ElevatedButton({Widget? child, void Function()? onPressed});
}
class IconButton extends Widget {
  const IconButton({Widget? icon, void Function()? onPressed});
  const IconButton.filled({Widget? icon, void Function()? onPressed});
}
class TextField extends Widget {
  const TextField();
}
class TextFormField extends Widget {
  const TextFormField();
}
class OutlinedButton extends Widget {
  const OutlinedButton({Widget? child, void Function()? onPressed});
}
class FilledButton extends Widget {
  const FilledButton({Widget? child, void Function()? onPressed});
}
enum MaterialTapTargetSize { padded, shrinkWrap }
class TextButton extends Widget {
  const TextButton({Widget? child, MaterialTapTargetSize? materialTapTargetSize});
}
''';

  @override
  void setUp() {
    newPackage('flutter').addFile('lib/widgets.dart', _stub);
    super.setUp();
  }

  static const import = "import 'package:flutter/widgets.dart';\n";
}
