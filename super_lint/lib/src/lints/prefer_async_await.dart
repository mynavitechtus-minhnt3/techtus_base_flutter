import '../index.dart';

class PreferAsyncAwait extends OptionsLintRule<_PreferAsyncAwaitOption> {
  PreferAsyncAwait(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: 'prefer_async_await',
            configs: configs,
            paramsParser: _PreferAsyncAwaitOption.fromMap,
            problemMessage: (_) => 'Prefer using async/await syntax instead of .then invocations',
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

class _PreferAsyncAwaitOption extends CommonLintOption {
  const _PreferAsyncAwaitOption({
    super.excludes,
    super.includes,
    super.severity,
  });

  static _PreferAsyncAwaitOption fromMap(Map<String, dynamic> map) {
    return _PreferAsyncAwaitOption(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
    );
  }
}
