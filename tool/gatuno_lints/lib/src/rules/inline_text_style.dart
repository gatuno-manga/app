import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../flutter_utils.dart';

/// Flags `TextStyle(fontSize/fontFamily/fontWeight: …)` outside the theme
/// layer. A `TextStyle(color: …)` is fine: it only recolors.
class InlineTextStyle extends AnalysisRule {
  static const LintCode code = LintCode(
    'inline_text_style',
    'Inline TextStyle sets typography the theme already owns.',
    severity: DiagnosticSeverity.WARNING,
    correctionMessage:
        'Use Theme.of(context).textTheme (optionally with copyWith).',
  );

  static const _typographyArguments = {'fontSize', 'fontFamily', 'fontWeight'};

  InlineTextStyle()
    : super(
        name: 'inline_text_style',
        description: 'Typography must come from the text theme.',
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
    if (!appliesTo(context)) return;
    if (flutterTypeName(node) != 'TextStyle') return;
    final sets = InlineTextStyle._typographyArguments.any(
      (name) => namedArgument(node, name) != null,
    );
    if (sets) rule.reportAtNode(node);
  }
}
