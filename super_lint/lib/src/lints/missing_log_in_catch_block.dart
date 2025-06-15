import '../index.dart';

class MissingLogInCatchBlock extends OptionsLintRule<_MissingLogInCatchBlockOption> {
  MissingLogInCatchBlock(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: lintName,
            configs: configs,
            paramsParser: _MissingLogInCatchBlockOption.fromMap,
            problemMessage: (_) =>
                'When using try/catch, the exception must be logged in the catch block',
          ),
        );

  static const String lintName = 'missing_log_in_catch_block';

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

class _MissingLogInCatchBlockOption extends Excludable {
  _MissingLogInCatchBlockOption({
    this.excludes = const [],
    this.includes = const [],
    this.methods = _defaultMethods,
    this.className = _defaultClassName,
    this.severity,
  });

  final ErrorSeverity? severity;
  @override
  final List<String> excludes;
  @override
  final List<String> includes;
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
