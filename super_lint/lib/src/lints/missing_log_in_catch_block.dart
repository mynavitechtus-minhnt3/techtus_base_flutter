import '../index.dart';

class MissingLogInCatchBlock extends OptionsLintRule<_MissingLogInCatchBlockOption> {
  MissingLogInCatchBlock(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: 'missing_log_in_catch_block',
            configs: configs,
            paramsParser: _MissingLogInCatchBlockOption.fromMap,
            problemMessage: (_) =>
                'When using try/catch, the exception must be logged in the catch block',
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

    context.registry.addCatchClause((node) {
      final methodInvocations = node.body.childMethodInvocations;
      final hasLog = methodInvocations.any((element) {
        return (element.realTarget?.staticType.toString() == config.parameters.className ||
                element.classNameOfStaticMethod == config.parameters.className) &&
            config.parameters.methods.contains(element.methodName.name);
      });

      if (!hasLog) {
        reporter.atNode(node, code);
      }
    });
  }
}

class _MissingLogInCatchBlockOption extends CommonLintOption {
  _MissingLogInCatchBlockOption({
    super.excludes,
    super.includes,
    this.methods = _defaultMethods,
    this.className = _defaultClassName,
    super.severity,
  });
  final List<String> methods;
  final String className;

  static _MissingLogInCatchBlockOption fromMap(Map<String, dynamic> map) {
    return _MissingLogInCatchBlockOption(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
      methods: safeCastToListString(map['methods'], defaultValue: _defaultMethods),
      className: safeCast(map['class_name']) ?? _defaultClassName,
    );
  }

  static const _defaultClassName = 'Log';
  static const _defaultMethods = ['e'];
}
