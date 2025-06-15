import '../index.dart';

class AvoidUsingTextStyleConstructorDirectly
    extends OptionsLintRule<_AvoidUsingTextStyleConstructorOption> {
  AvoidUsingTextStyleConstructorDirectly(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: lintName,
            configs: configs,
            paramsParser: _AvoidUsingTextStyleConstructorOption.fromMap,
            problemMessage: (_) =>
                'Avoid using TextStyle constructor directly, use the style function instead.',
          ),
        );

  static const String lintName = 'avoid_using_text_style_constructor_directly';

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

class _AvoidUsingTextStyleConstructorOption extends Excludable {
  const _AvoidUsingTextStyleConstructorOption({
    this.excludes = const [],
    this.includes = const [],
    this.severity,
  });

  final ErrorSeverity? severity;
  @override
  final List<String> excludes;
  @override
  final List<String> includes;

  static _AvoidUsingTextStyleConstructorOption fromMap(Map<String, dynamic> map) {
    return _AvoidUsingTextStyleConstructorOption(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
    );
  }
}
