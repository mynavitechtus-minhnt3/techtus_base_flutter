import '../index.dart';

class IncorrectScreenNameParameterValue
    extends OptionsLintRule<_IncorrectScreenNameParameterValueOption> {
  IncorrectScreenNameParameterValue(CustomLintConfigs configs)
      : super(
          RuleConfig(
            name: 'incorrect_screen_name_parameter_value',
            configs: configs,
            paramsParser: _IncorrectScreenNameParameterValueOption.fromMap,
            problemMessage: (params) => 'The screenName does not match the file name.',
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

    final fileName = resolver.path.split('/').last.split('.').first;
    final expectedScreenName = fileName.toCamelCase();

    context.registry.addInstanceCreationExpression((node) {
      final arguments = node.argumentList.arguments;
      for (final arg in arguments) {
        if (arg is NamedExpression &&
            arg.name.label.name == 'screenName' &&
            arg.expression is PrefixedIdentifier) {
          final screenName = (arg.expression as PrefixedIdentifier).identifier.name;
          if (screenName != expectedScreenName) {
            reporter.atNode(
              arg.expression,
              code.copyWith(
                problemMessage:
                    'The screenName "$screenName" does not match the expected file name "$fileName".',
              ),
            );
          }
        }
      }
    });
  }

  @override
  List<Fix> getFixes() {
    return [
      _FixIncorrectScreenName(config),
    ];
  }
}

class _FixIncorrectScreenName extends OptionsFix<_IncorrectScreenNameParameterValueOption> {
  _FixIncorrectScreenName(super.config);

  @override
  Future<void> run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) async {
    final fileName = resolver.path.split('/').last.split('.').first;
    final expectedScreenName = fileName.toCamelCase();

    final changeBuilder = reporter.createChangeBuilder(
      message: 'Replace screenName with $expectedScreenName.',
      priority: 50,
    );

    changeBuilder.addDartFileEdit((builder) {
      builder.addSimpleReplacement(
        analysisError.sourceRange,
        'ScreenName.$expectedScreenName',
      );
    });
  }
}

class _IncorrectScreenNameParameterValueOption extends CommonLintOption {
  const _IncorrectScreenNameParameterValueOption({
    super.excludes,
    super.includes,
    super.severity,
  });

  static _IncorrectScreenNameParameterValueOption fromMap(Map<String, dynamic> map) {
    return _IncorrectScreenNameParameterValueOption(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
    );
  }
}
