import '../index.dart';

class AvoidUsingDateTimeNow extends CommonLintRule<_AvoidUsingDateTimeNowParameter> {
  AvoidUsingDateTimeNow(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: 'avoid_using_datetime_now',
            configs: configs,
            paramsParser: _AvoidUsingDateTimeNowParameter.fromMap,
            problemMessage: (_) => "Avoid using DateTime.now(), use 'now' instead.",
          ),
        );

  @override
  Future<void> check(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
    String rootPath,
  ) async {
    context.registry.addInstanceCreationExpression((node) {
      final type = node.constructorName.type.type;
      final name = node.constructorName.name?.name;
      if (type?.getDisplayString() == 'DateTime' && name == 'now') {
        reporter.atNode(node, code);
      }
    });
  }

  @override
  List<Fix> getFixes() => [
        _AvoidUsingDateTimeNowFix(config),
      ];
}

class _AvoidUsingDateTimeNowFix extends CommonQuickFix<_AvoidUsingDateTimeNowParameter> {
  _AvoidUsingDateTimeNowFix(super.config);

  @override
  Future<void> run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) async {
    context.registry.addInstanceCreationExpression((node) {
      final sourceRange = node.sourceRange;
      if (!sourceRange.intersects(analysisError.sourceRange)) {
        return;
      }
      final type = node.constructorName.type.type;
      final name = node.constructorName.name?.name;
      if (type?.getDisplayString() == 'DateTime' && name == 'now') {
        final changeBuilder = reporter.createChangeBuilder(
          message: "Replace with 'now'",
          priority: 70,
        );
        changeBuilder.addDartFileEdit((builder) {
          builder.addSimpleReplacement(sourceRange, 'now');
        });
      }
    });
  }
}

class _AvoidUsingDateTimeNowParameter extends CommonLintParameter {
  const _AvoidUsingDateTimeNowParameter({
    super.excludes = const [],
    super.includes = const [],
    super.severity,
  });

  static _AvoidUsingDateTimeNowParameter fromMap(Map<String, dynamic> map) {
    return _AvoidUsingDateTimeNowParameter(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
    );
  }
}
