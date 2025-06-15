import '../index.dart';

class PreferAsyncAwait extends CommonLintRule<_PreferAsyncAwaitParameter> {
  PreferAsyncAwait(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: 'prefer_async_await',
            configs: configs,
            paramsParser: _PreferAsyncAwaitParameter.fromMap,
            problemMessage: (_) => 'Prefer using async/await syntax instead of .then invocations',
          ),
        );

  @override
  Future<void> check(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
    String rootPath,
  ) async {
    context.registry.addMethodInvocation((node) {
      final target = node.realTarget;
      if (target == null) return;

      final targetType = target.staticType;
      if (targetType == null || !targetType.isDartAsyncFuture) return;

      final methodName = node.methodName.name;
      if (methodName != 'then') return;

      reporter.atNode(node.methodName, code);
    });
  }
}

class _PreferAsyncAwaitParameter extends CommonLintParameter {
  const _PreferAsyncAwaitParameter({
    super.excludes,
    super.includes,
    super.severity,
  });

  static _PreferAsyncAwaitParameter fromMap(Map<String, dynamic> map) {
    return _PreferAsyncAwaitParameter(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
    );
  }
}
