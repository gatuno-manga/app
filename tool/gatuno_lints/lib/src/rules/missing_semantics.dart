import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../flutter_utils.dart';

/// Heuristic: a bare `GestureDetector`/`InkWell` exposes a tap action but no
/// label. Flags it when neither an enclosing widget in the same expression
/// nor its own subtree supplies a label, and the subtree is fully visible
/// (no app widgets or externally built children) (`Semantics`, `Tooltip`, `Text`, or a
/// `semanticLabel`/`tooltip` argument).
class MissingSemantics extends AnalysisRule {
  static const LintCode code = LintCode(
    'missing_semantics',
    'Tappable widget has no accessible label.',
    severity: DiagnosticSeverity.WARNING,
    correctionMessage:
        'Wrap it in Semantics(label: ...), add a Tooltip, or give it a '
        'labelled child.',
  );

  static const _tappable = {'GestureDetector', 'InkWell', 'InkResponse'};
  static const _labelling = {
    'Semantics',
    'MergeSemantics',
    'Tooltip',
    'Text',
    'RichText',
  };
  static const _labelArguments = {'semanticLabel', 'tooltip', 'label'};

  MissingSemantics()
    : super(
        name: 'missing_semantics',
        description: 'Tappable widgets need an accessible label.',
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
    final type = flutterTypeName(node);
    if (type == null || !MissingSemantics._tappable.contains(type)) return;
    if (_hasLabelAbove(node) || _hasLabelOrUnknownWithin(node)) return;
    rule.reportAtNode(node.constructorName);
  }

  /// Walks up through enclosing widget expressions, stopping at the
  /// enclosing function or class member (a different widget).
  bool _hasLabelAbove(AstNode node) {
    for (var parent = node.parent; parent != null; parent = parent.parent) {
      if (parent is FunctionBody || parent is ClassMember) return false;
      if (parent is InstanceCreationExpression) {
        final type = flutterTypeName(parent);
        if (type != null && MissingSemantics._labelling.contains(type)) {
          return true;
        }
      }
    }
    return false;
  }

  /// True when the subtree supplies a label, or holds content the rule
  /// cannot inspect (an app widget, or a `child` that is not built inline):
  /// those may well be labelled, and flagging them would be noise.
  bool _hasLabelOrUnknownWithin(InstanceCreationExpression node) {
    final child = namedArgument(node, 'child');
    if (child != null && child is! InstanceCreationExpression) return true;

    var found = false;
    forEachCreation(node, (creation, type) {
      if (type == null || MissingSemantics._labelling.contains(type)) {
        found = true;
      }
      for (final name in MissingSemantics._labelArguments) {
        if (namedArgument(creation, name) != null) found = true;
      }
    });
    return found;
  }
}
