import '../index.dart';

class EmptyTestGroup extends CommonLintRule<_EmptyTestGroupOption> {
  EmptyTestGroup(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: lintName,
            configs: configs,
            paramsParser: _EmptyTestGroupOption.fromMap,
            problemMessage: (_) =>
                'Each group(...) in test files must contain at least one test case.',
          ),
        );

  static const String lintName = 'empty_test_group';

  @override
  Future<void> check(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
    String rootPath,
  ) async {
    if (!resolver.path.endsWith('_test.dart')) {
      return;
    }

    final code = this.code.copyWith(
          errorSeverity: parameters.severity ?? this.code.errorSeverity,
        );

    context.registry.addMethodInvocation((node) {
      if (node.methodName.name != 'group') {
        return;
      }

      if (node.argumentList.arguments.length < 2) {
        return;
      }

      final firstArg = node.argumentList.arguments.first;
      if (firstArg is! StringLiteral) {
        return;
      }

      final groupName = firstArg.stringValue ?? '';

      final bodyArg = node.argumentList.arguments[1];
      final bodySource = bodyArg.toSource();

      final hasAnyTest = _containsAnyTestInvocation(bodySource);
      if (!hasAnyTest) {
        reporter.atNode(
          firstArg,
          code.copyWith(
            problemMessage:
                'Group "$groupName" does not contain any test cases (test/testWidgets/testGoldens/stateNotifierTest).',
          ),
        );
      }
    });
  }

  bool _containsAnyTestInvocation(String source) {
    return source.contains('test(') ||
        source.contains('testWidgets(') ||
        source.contains('testGoldens(') ||
        source.contains('stateNotifierTest(');
  }
}

class _EmptyTestGroupOption extends CommonLintParameter {
  const _EmptyTestGroupOption({
    super.excludes = const [],
    super.includes = const [],
    super.severity,
  });

  static _EmptyTestGroupOption fromMap(Map<String, dynamic> map) {
    return _EmptyTestGroupOption(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
    );
  }
}
