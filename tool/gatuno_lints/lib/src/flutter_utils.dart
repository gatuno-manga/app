import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

/// Whether the rules apply to the unit being analysed: app code under `lib/`,
/// except the theme layer, which is where tokens are legitimately defined.
bool appliesTo(RuleContext context) {
  if (!context.isInLibDir) return false;
  return !_unitPath(context).contains('/lib/core/theme/');
}

/// Whether the unit being analysed is an atom: any file under a
/// `components/atoms/` folder, shared or feature-level.
bool isAtomFile(RuleContext context) =>
    _unitPath(context).contains('/components/atoms/');

String _unitPath(RuleContext context) =>
    context.currentUnit?.file.path.replaceAll(r'\', '/') ?? '';

/// Whether [element] is declared by Flutter (or `dart:ui`).
bool isFlutterElement(Element? element) {
  final uri = element?.library?.uri;
  if (uri == null) return false;
  return (uri.scheme == 'dart' && uri.path == 'ui') ||
      (uri.scheme == 'package' && uri.pathSegments.first == 'flutter');
}

/// Name of the Flutter class [node] constructs, or null when it is not a
/// Flutter class.
String? flutterTypeName(InstanceCreationExpression node) {
  final element = node.constructorName.type.element;
  if (element == null || !isFlutterElement(element)) return null;
  return element.name;
}

/// The literal number of [expression], or null when it is not a plain
/// numeric literal.
num? numericLiteral(Expression? expression) {
  final e = expression;
  if (e is IntegerLiteral) return e.value;
  if (e is DoubleLiteral) return e.value;
  return null;
}

/// The expression of [argument], named or positional.
Expression argumentExpression(Argument argument) => argument is NamedArgument
    ? argument.argumentExpression
    : argument as Expression;

/// The named argument [name] of [node], or null.
Expression? namedArgument(InstanceCreationExpression node, String name) {
  for (final argument in node.argumentList.arguments) {
    if (argument is NamedArgument && argument.name.lexeme == name) {
      return argument.argumentExpression;
    }
  }
  return null;
}

/// Runs [onCreation] on every instance creation under [root], [root]
/// included. `type` is the Flutter class name, or null for any other class
/// (an app widget whose content the rules cannot see).
void forEachCreation(
  AstNode root,
  void Function(InstanceCreationExpression node, String? type) onCreation,
) {
  root.accept(_CreationWalker(onCreation));
}

class _CreationWalker extends RecursiveAstVisitor<void> {
  _CreationWalker(this.onCreation);

  final void Function(InstanceCreationExpression, String?) onCreation;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    onCreation(node, flutterTypeName(node));
    super.visitInstanceCreationExpression(node);
  }
}
