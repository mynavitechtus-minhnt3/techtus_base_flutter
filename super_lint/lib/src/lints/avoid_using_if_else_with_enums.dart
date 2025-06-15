import '../index.dart';

class AvoidUsingIfElseWithEnums extends OptionsLintRule<_AvoidUsingIfElseWithEnumsOption> {
  AvoidUsingIfElseWithEnums(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: lintName,
            configs: configs,
            paramsParser: _AvoidUsingIfElseWithEnumsOption.fromMap,
            problemMessage: (_) => 'Avoid using if-else with enums. Use switch-case instead.',
          ),
        );

  static const String lintName = 'avoid_using_if_else_with_enums';

  @override
  Future<void> run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) async {
    final rootPath = await resolver.rootPath;
    final parameters = config.parameters;
    if (parameters.shouldSkipAnalysis(
      path: resolver.path,
      rootPath: rootPath,
    )) {
      return;
    }

    final code = this.code.copyWith(
          errorSeverity: parameters.severity ?? this.code.errorSeverity,
        );

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

    if (config.parameters.includeConditionalExpression) {
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

class _AvoidUsingIfElseWithEnumsOption extends Excludable {
  const _AvoidUsingIfElseWithEnumsOption({
    this.excludes = const [],
    this.includes = const [],
    this.severity,
    this.includeConditionalExpression = true,
  });

  final ErrorSeverity? severity;
  @override
  final List<String> excludes;
  @override
  final List<String> includes;
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
