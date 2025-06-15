import '../index.dart';

class AvoidNestedConditions extends OptionsLintRule<_AvoidNestedConditionsOption> {
  AvoidNestedConditions(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: 'avoid_nested_conditions',
            configs: configs,
            paramsParser: _AvoidNestedConditionsOption.fromMap,
            problemMessage: (_) => 'Avoid nested conditions; use early return instead.',
          ),
        );


  final _nestingConditionalExpressionLevels = <ConditionalExpression, int>{};
  final _nestingIfStatementLevels = <IfStatement, int>{};

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

    context.registry.addConditionalExpression((node) {
      final parent = node.parent?.thisOrAncestorOfType<ConditionalExpression>();
      final level = (_nestingConditionalExpressionLevels[parent] ?? 0) + 1;
      _nestingConditionalExpressionLevels[node] = level;

      if ((_nestingConditionalExpressionLevels[node] ?? -1) > parameters.acceptableLevel) {
        reporter.atNode(
          node,
          code,
        );
      }
    });

    context.registry.addIfStatement((node) {
      final parent = node.parent?.thisOrAncestorOfType<IfStatement>();
      final level = (_nestingIfStatementLevels[parent] ?? 0) + 1;
      _nestingIfStatementLevels[node] = level;

      if ((_nestingIfStatementLevels[node] ?? -1) > parameters.acceptableLevel) {
        reporter.atNode(
          node,
          code,
        );
      }
    });
  }
}

class _AvoidNestedConditionsOption extends CommonLintOption {
  const _AvoidNestedConditionsOption({
    super.excludes,
    super.includes,
    super.severity,
    this.acceptableLevel = _defaultAcceptableLevel,
  });
  final int acceptableLevel;

  static _AvoidNestedConditionsOption fromMap(Map<String, dynamic> map) {
    return _AvoidNestedConditionsOption(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
      acceptableLevel: safeCast(map['acceptable_level']) ?? _defaultAcceptableLevel,
    );
  }

  static const int _defaultAcceptableLevel = 2;
}
