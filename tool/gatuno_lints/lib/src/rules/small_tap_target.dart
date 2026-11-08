import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../flutter_utils.dart';

/// Flags interactive widgets whose tap target is below 48dp. Only literal
/// sizes are inspected; computed sizes are out of scope.
class SmallTapTarget extends AnalysisRule {
  static const LintCode code = LintCode(
    'small_tap_target',
    'Tap target is smaller than 48dp.',
    severity: DiagnosticSeverity.WARNING,
    correctionMessage:
        'Give interactive widgets at least 48x48dp, or pad the hit area.',
  );

  static const double minimum = 48;

  /// Widgets that react to taps.
  static const tappable = {
    'InkWell',
    'InkResponse',
    'GestureDetector',
    'IconButton',
    'TextButton',
    'ElevatedButton',
    'OutlinedButton',
    'FilledButton',
  };

  /// Widgets that impose a fixed size on their child.
  static const _sizers = {'SizedBox', 'Container', 'ConstrainedBox'};

  SmallTapTarget()
    : super(
        name: 'small_tap_target',
        description: 'Interactive widgets need a 48dp tap target.',
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
    if (type == null) return;

    if (SmallTapTarget._sizers.contains(type)) {
      _checkSizer(node);
    } else if (SmallTapTarget.tappable.contains(type)) {
      _checkShrinkWrap(node);
    }
  }

  /// `SizedBox(width: 24, child: InkWell(...))` and friends.
  void _checkSizer(InstanceCreationExpression sizer) {
    final child = namedArgument(sizer, 'child');
    if (child is! InstanceCreationExpression) return;
    final childType = flutterTypeName(child);
    if (childType == null || !SmallTapTarget.tappable.contains(childType)) {
      return;
    }
    for (final name in const ['width', 'height']) {
      final size = numericLiteral(namedArgument(sizer, name));
      if (size != null && size < SmallTapTarget.minimum) {
        rule.reportAtNode(sizer);
        return;
      }
    }
  }

  /// `materialTapTargetSize: MaterialTapTargetSize.shrinkWrap` drops the
  /// button below the minimum.
  void _checkShrinkWrap(InstanceCreationExpression button) {
    final size = namedArgument(button, 'materialTapTargetSize');
    if (size is PrefixedIdentifier && size.identifier.name == 'shrinkWrap') {
      rule.reportAtNode(size);
    }
  }
}
