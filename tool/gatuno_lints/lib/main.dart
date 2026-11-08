import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import 'src/rules/hardcoded_color.dart';
import 'src/rules/inline_text_style.dart';
import 'src/rules/missing_semantics.dart';
import 'src/rules/raw_widget_outside_atoms.dart';
import 'src/rules/small_tap_target.dart';

/// Entry point the analysis server loads (see `plugins:` in the app's
/// `analysis_options.yaml`).
final plugin = GatunoLintsPlugin();

class GatunoLintsPlugin extends Plugin {
  @override
  String get name => 'gatuno_lints';

  @override
  void register(PluginRegistry registry) {
    registry
      ..registerWarningRule(HardcodedColor())
      ..registerWarningRule(InlineTextStyle())
      ..registerWarningRule(MissingSemantics())
      ..registerWarningRule(RawWidgetOutsideAtoms())
      ..registerWarningRule(SmallTapTarget());
  }
}
