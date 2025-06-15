import '../index.dart';

class MissingLogInCatchBlock extends CommonLintRule<_MissingLogInCatchBlockParameter> {
  MissingLogInCatchBlock(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: 'missing_log_in_catch_block',
            configs: configs,
            paramsParser: _MissingLogInCatchBlockParameter.fromMap,
            problemMessage: (_) =>
                'When using try/catch, the exception must be logged in the catch block',
          ),
        );

  @override
  Future<void> check(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
    String rootPath,
  ) async {
    context.registry.addCatchClause((node) {
      final methodInvocations = node.body.childMethodInvocations;
      final hasLog = methodInvocations.any((element) {
        return (element.realTarget?.staticType.toString() == parameters.className ||
                element.classNameOfStaticMethod == parameters.className) &&
            parameters.methods.contains(element.methodName.name);
      });

      if (!hasLog) {
        reporter.atNode(node, code);
      }
    });
  }
}

class _MissingLogInCatchBlockParameter extends CommonLintParameter {
  _MissingLogInCatchBlockParameter({
    super.excludes,
    super.includes,
    this.methods = _defaultMethods,
    this.className = _defaultClassName,
    super.severity,
  });
  final List<String> methods;
  final String className;

  static _MissingLogInCatchBlockParameter fromMap(Map<String, dynamic> map) {
    return _MissingLogInCatchBlockParameter(
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
