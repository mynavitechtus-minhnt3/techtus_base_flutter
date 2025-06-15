import '../index.dart';

class AvoidUsingIfElseWithEnums extends CommonLintRule<_AvoidUsingIfElseWithEnumsOption> {
  AvoidUsingIfElseWithEnums(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: 'avoid_using_if_else_with_enums',
            configs: configs,
            paramsParser: _AvoidUsingIfElseWithEnumsOption.fromMap,
            problemMessage: (_) => 'Avoid using if-else with enums. Use switch-case instead.',
          ),
        );

  @override
  Future<void> check(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
    String rootPath,
  ) async {
    context.registry.addIfStatement((node) {
      if (node.expression is! BinaryExpression) {
        return;
      }

      final binaryExpression = node.expression as BinaryExpression;
      if (binaryExpression.operator.type != TokenType.EQ_EQ &&
          binaryExpression.operator.type != TokenType.BANG_EQ) {
        return;
      }

      final leftOperand = binaryExpression.leftOperand;
      final rightOperand = binaryExpression.rightOperand;

      final leftClassElement = leftOperand.staticType?.isEnum ?? false;
      final rightClassElement = rightOperand.staticType?.isEnum ?? false;

      if (leftClassElement && rightClassElement) {
        reporter.atNode(node, code);
      }
    });

    if (parameters.includeConditionalExpression) {
      context.registry.addConditionalExpression((node) {
        final condition = node.condition;
        if (condition is! BinaryExpression) {
          return;
        }

        final binaryExpression = condition;
        if (binaryExpression.operator.type != TokenType.EQ_EQ &&
            binaryExpression.operator.type != TokenType.BANG_EQ) {
          return;
        }

        final leftOperand = binaryExpression.leftOperand;
        final rightOperand = binaryExpression.rightOperand;

        final leftClassElement = leftOperand.staticType?.isEnum ?? false;
        final rightClassElement = rightOperand.staticType?.isEnum ?? false;

        if (leftClassElement && rightClassElement) {
          reporter.atNode(node, code);
        }
      });
    }
  }
}

class _AvoidUsingIfElseWithEnumsOption extends CommonLintParameter {
  const _AvoidUsingIfElseWithEnumsOption({
    super.excludes,
    super.includes,
    super.severity,
    this.includeConditionalExpression = true,
  });
  final bool includeConditionalExpression;

  static _AvoidUsingIfElseWithEnumsOption fromMap(Map<String, dynamic> map) {
    return _AvoidUsingIfElseWithEnumsOption(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
      includeConditionalExpression: map['include_conditional_expression'] ?? true,
    );
  }
}
