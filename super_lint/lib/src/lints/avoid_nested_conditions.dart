import '../index.dart';

class AvoidNestedConditions extends CommonLintRule<_AvoidNestedConditionsParameter> {
  AvoidNestedConditions(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: 'avoid_nested_conditions',
            configs: configs,
            paramsParser: _AvoidNestedConditionsParameter.fromMap,
            problemMessage: (_) => 'Avoid nested conditions; use early return instead.',
          ),
        );

  final _nestingConditionalExpressionLevels = <ConditionalExpression, int>{};
  final _nestingIfStatementLevels = <IfStatement, int>{};

  @override
  Future<void> check(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
    String rootPath,
  ) async {
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

class _AvoidNestedConditionsParameter extends CommonLintParameter {
  const _AvoidNestedConditionsParameter({
    super.excludes,
    super.includes,
    super.severity,
    this.acceptableLevel = _defaultAcceptableLevel,
  });
  final int acceptableLevel;

  static _AvoidNestedConditionsParameter fromMap(Map<String, dynamic> map) {
    return _AvoidNestedConditionsParameter(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
      acceptableLevel: safeCast(map['acceptable_level']) ?? _defaultAcceptableLevel,
    );
  }

  static const int _defaultAcceptableLevel = 2;
}
