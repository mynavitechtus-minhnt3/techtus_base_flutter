import '../index.dart';

class PreferIsEmptyString extends OptionsLintRule<_PreferIsEmptyStringOption> {
  PreferIsEmptyString(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: 'prefer_is_empty_string',
            configs: configs,
            paramsParser: _PreferIsEmptyStringOption.fromMap,
            problemMessage: (_) =>
                'Use \'isEmpty\' instead of \'==\' to test whether the string is empty.\nTry rewriting the expression to use \'isEmpty\'.',
          ),
        );


  @override
  Future<void> run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) async {
    final runCtx = await prepareRun(resolver);
    if (runCtx == null) return;
    final code = runCtx.code;
    final parameters = runCtx.parameters;

    context.registry.addBinaryExpression((node) {
      if (node.operator.type == TokenType.EQ_EQ &&
          (node.leftOperand.toString() == '\'\'' || node.rightOperand.toString() == '\'\'')) {
        reporter.atNode(node, code);
      }
    });
  }

  @override
  List<Fix> getFixes() => [
        _ReplaceWithIsEmpty(config),
      ];
}

class _ReplaceWithIsEmpty extends OptionsFix<_PreferIsEmptyStringOption> {
  _ReplaceWithIsEmpty(super.config);

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
          node.operator.type != TokenType.EQ_EQ ||
          (node.leftOperand.toString() != '\'\'' && node.rightOperand.toString() != '\'\'')) {
        return;
      }

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with \'isEmpty\'',
        priority: 71,
      );

      final variable = node.leftOperand.toString() == '\'\'' ? node.rightOperand : node.leftOperand;

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(
            node.sourceRange,
            variable.staticType?.isNullableType == true
                ? '${variable.toString()}?.isEmpty == true'
                : '${variable.toString()}.isEmpty');
      });
    });
  }
}

class _PreferIsEmptyStringOption extends CommonLintOption {
  const _PreferIsEmptyStringOption({
    super.excludes,
    super.includes,
    super.severity,
  });

  static _PreferIsEmptyStringOption fromMap(Map<String, dynamic> map) {
    return _PreferIsEmptyStringOption(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
    );
  }
}
