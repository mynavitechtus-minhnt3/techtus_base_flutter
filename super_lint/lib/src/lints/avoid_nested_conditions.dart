import '../index.dart';

class AvoidNestedConditions extends OptionsLintRule<_AvoidNestedConditionsOption> {
  AvoidNestedConditions(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: lintName,
            configs: configs,
            paramsParser: _AvoidNestedConditionsOption.fromMap,
            problemMessage: (_) => 'Avoid nested conditions; use early return instead.',
          ),
        );

  static const String lintName = 'avoid_nested_conditions';

  final _nestingConditionalExpressionLevels = <ConditionalExpression, int>{};
  final _nestingIfStatementLevels = <IfStatement, int>{};

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

class _AvoidNestedConditionsOption extends Excludable {
  const _AvoidNestedConditionsOption({
    this.excludes = const [],
    this.includes = const [],
    this.severity,
    this.acceptableLevel = _defaultAcceptableLevel,
  });

  final ErrorSeverity? severity;
  @override
  final List<String> excludes;
  @override
  final List<String> includes;
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
