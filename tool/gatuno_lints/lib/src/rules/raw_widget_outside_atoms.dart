import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../flutter_utils.dart';

/// Flags Material buttons and text fields built directly in a molecule,
/// organism, template or page. Those tiers compose the app atoms
/// (`AppButton`, `AppIconButton`, `AppTextField`); only an atom may wrap the
/// raw Flutter widget.
class RawWidgetOutsideAtoms extends AnalysisRule {
  static const LintCode code = LintCode(
    'raw_widget_outside_atoms',
    'Raw Material widget built outside an atom.',
    severity: DiagnosticSeverity.INFO,
    correctionMessage:
        'Use AppButton, AppIconButton or AppTextField, or extract a new atom '
        'under components/atoms/.',
  );

  /// Flutter widgets that only atoms may build.
  static const rawWidgets = {
    'ElevatedButton',
    'TextButton',
    'OutlinedButton',
    'FilledButton',
    'IconButton',
    'TextField',
    'TextFormField',
  };

  RawWidgetOutsideAtoms()
    : super(
        name: 'raw_widget_outside_atoms',
        description: 'Buttons and text fields are built by atoms only.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addInstanceCreationExpression(this, _Visitor(this, context));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (!appliesTo(context) || _isAtom()) return;
    if (!RawWidgetOutsideAtoms.rawWidgets.contains(flutterTypeName(node))) {
      return;
    }
    rule.reportAtNode(node.constructorName);
  }

  bool _isAtom() {
    final path = context.currentUnit?.file.path.replaceAll(r'\', '/') ?? '';
    return path.contains('/components/atoms/');
  }
}
