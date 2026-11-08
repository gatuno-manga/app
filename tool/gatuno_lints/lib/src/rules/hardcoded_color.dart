import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../flutter_utils.dart';

/// Flags all-literal `Color(...)` constructors and `Colors.*` outside the
/// theme layer. `Colors.transparent` is allowed: it is the absence of a
/// color, not a design token.
class HardcodedColor extends AnalysisRule {
  static const LintCode code = LintCode(
    'hardcoded_color',
    'Hardcoded color bypasses the theme.',
    severity: DiagnosticSeverity.WARNING,
    correctionMessage:
        'Read it from Theme.of(context).colorScheme or the GatunoColors '
        'palette instead.',
  );

  HardcodedColor()
    : super(
        name: 'hardcoded_color',
        description: 'Colors must come from the theme, not literals.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _Visitor(this, context);
    registry
      ..addPrefixedIdentifier(this, visitor)
      ..addInstanceCreationExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (!appliesTo(context)) return;
    if (node.prefix.name != 'Colors') return;
    if (!isFlutterElement(node.identifier.element)) return;
    if (node.identifier.name == 'transparent') return;
    rule.reportAtNode(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (!appliesTo(context)) return;
    if (flutterTypeName(node) != 'Color') return;
    // Color(int.parse(...)) is data (e.g. a cover's dominant color), not a
    // design decision; only fully literal colors are hardcoded.
    final allLiteral = node.argumentList.arguments.every(
      (argument) => numericLiteral(argumentExpression(argument)) != null,
    );
    if (allLiteral) rule.reportAtNode(node);
  }
}
