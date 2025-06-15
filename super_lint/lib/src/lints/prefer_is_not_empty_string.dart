import '../index.dart';

class PreferIsNotEmptyString extends CommonLintRule<_PreferIsNotEmptyStringParameter> {
  PreferIsNotEmptyString(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: 'prefer_is_not_empty_string',
            configs: configs,
            paramsParser: _PreferIsNotEmptyStringParameter.fromMap,
            problemMessage: (_) =>
                'Use \'isNotEmpty\' instead of \'!=\' to test whether the string is empty.\nTry rewriting the expression to use \'isNotEmpty\'.',
          ),
        );

  @override
  Future<void> check(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
    String rootPath,
  ) async {
    context.registry.addBinaryExpression((node) {
      if (node.operator.type == TokenType.BANG_EQ &&
          (node.leftOperand.toString() == '\'\'' || node.rightOperand.toString() == '\'\'')) {
        reporter.atNode(node, code);
      }
    });
  }

  @override
  List<Fix> getFixes() => [
        _PreferIsNotEmptyStringFix(config),
      ];
}

class _PreferIsNotEmptyStringFix extends CommonQuickFix<_PreferIsNotEmptyStringParameter> {
  _PreferIsNotEmptyStringFix(super.config);

  @override
  Future<void> run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) async {
    context.registry.addBinaryExpression((node) {
      if (!node.sourceRange.intersects(analysisError.sourceRange) ||
          node.operator.type != TokenType.BANG_EQ ||
          (node.leftOperand.toString() != '\'\'' && node.rightOperand.toString() != '\'\'')) {
        return;
      }

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with \'isNotEmpty\'',
        priority: 70,
      );

      final variable = node.leftOperand.toString() == '\'\'' ? node.rightOperand : node.leftOperand;

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(
            node.sourceRange,
            variable.staticType?.isNullableType == true
                ? '${variable.toString()}?.isNotEmpty == true'
                : '${variable.toString()}.isNotEmpty');
      });
    });
  }
}

class _PreferIsNotEmptyStringParameter extends CommonLintParameter {
  const _PreferIsNotEmptyStringParameter({
    super.excludes,
    super.includes,
    super.severity,
  });

  static _PreferIsNotEmptyStringParameter fromMap(Map<String, dynamic> map) {
    return _PreferIsNotEmptyStringParameter(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
    );
  }
}
