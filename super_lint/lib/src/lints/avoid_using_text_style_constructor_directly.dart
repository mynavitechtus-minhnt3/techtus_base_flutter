import '../index.dart';

class AvoidUsingTextStyleConstructorDirectly
    extends OptionsLintRule<_AvoidUsingTextStyleConstructorOption> {
  AvoidUsingTextStyleConstructorDirectly(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: 'avoid_using_text_style_constructor_directly',
            configs: configs,
            paramsParser: _AvoidUsingTextStyleConstructorOption.fromMap,
            problemMessage: (_) =>
                'Avoid using TextStyle constructor directly, use the style function instead.',
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

    context.registry.addInstanceCreationExpression((node) {
      if (node.constructorName.type.type.toString() == 'TextStyle') {
        reporter.atNode(node, code);
      }
    });
  }

  @override
  List<Fix> getFixes() => [
        _ReplaceTextStyleWithStyleFunction(config),
      ];
}

class _ReplaceTextStyleWithStyleFunction extends OptionsFix<_AvoidUsingTextStyleConstructorOption> {
  _ReplaceTextStyleWithStyleFunction(super.config);

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

class _AvoidUsingTextStyleConstructorOption extends CommonLintOption {
  const _AvoidUsingTextStyleConstructorOption({
    super.excludes,
    super.includes,
    super.severity,
  });

  static _AvoidUsingTextStyleConstructorOption fromMap(Map<String, dynamic> map) {
    return _AvoidUsingTextStyleConstructorOption(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
    );
  }
}
