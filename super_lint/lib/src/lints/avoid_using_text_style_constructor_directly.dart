import '../index.dart';

class AvoidUsingTextStyleConstructorDirectly
    extends CommonLintRule<_AvoidUsingTextStyleConstructorDirectlyParameter> {
  AvoidUsingTextStyleConstructorDirectly(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: 'avoid_using_text_style_constructor_directly',
            configs: configs,
            paramsParser: _AvoidUsingTextStyleConstructorDirectlyParameter.fromMap,
            problemMessage: (_) =>
                'Avoid using TextStyle constructor directly, use the style function instead.',
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
      if (node.constructorName.type.type.toString() == 'TextStyle') {
        reporter.atNode(node, code);
      }
    });
  }

  @override
  List<Fix> getFixes() => [
        _AvoidUsingTextStyleConstructorDirectlyFix(config),
      ];
}

class _AvoidUsingTextStyleConstructorDirectlyFix
    extends CommonQuickFix<_AvoidUsingTextStyleConstructorDirectlyParameter> {
  _AvoidUsingTextStyleConstructorDirectlyFix(super.config);

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
      if (node.constructorName.type.type.toString() == 'TextStyle') {
        final changeBuilder = reporter.createChangeBuilder(
          message: 'Replace `TextStyle` constructor with `style` function',
          priority: 79,
        );

        changeBuilder.addDartFileEdit((builder) {
          builder.addSimpleReplacement(
            sourceRange,
            'style(${node.argumentList.arguments.join(', ')})',
          );
        });
      }
    });
  }
}

class _AvoidUsingTextStyleConstructorDirectlyParameter extends CommonLintParameter {
  const _AvoidUsingTextStyleConstructorDirectlyParameter({
    super.excludes,
    super.includes,
    super.severity,
  });

  static _AvoidUsingTextStyleConstructorDirectlyParameter fromMap(Map<String, dynamic> map) {
    return _AvoidUsingTextStyleConstructorDirectlyParameter(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
    );
  }
}
