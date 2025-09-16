import '../index.dart';

class MissingTestGroup extends CommonLintRule<_MissingTestGroupOption> {
  MissingTestGroup(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
              name: lintName,
              configs: configs,
              paramsParser: _MissingTestGroupOption.fromMap,
              problemMessage: (_) => 'Test files must declare all required groups.'),
        );

  static const String lintName = 'missing_test_group';

  @override
  Future<void> check(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
    String rootPath,
  ) async {
    // Only check test files
    if (!resolver.path.endsWith('_test.dart')) {
      return;
    }

    final code = this.code.copyWith(
          errorSeverity: parameters.severity ?? this.code.errorSeverity,
        );

    final groupDeclarations = <String>[];
    dynamic mainFunctionNode;

    context.registry.addFunctionDeclaration((node) {
      if (node.name.lexeme == 'main') {
        mainFunctionNode = node;
      }
    });

    context.registry.addMethodInvocation((node) {
      if (node.methodName.name == 'group') {
        if (node.argumentList.arguments.isNotEmpty &&
            node.argumentList.arguments[0] is StringLiteral) {
          final groupName = (node.argumentList.arguments[0] as StringLiteral).stringValue;
          if (groupName != null) {
            groupDeclarations.add(groupName);
          }
        }
      }
    });

    // Check after analyzing the entire file
    context.addPostRunCallback(() {
      if (mainFunctionNode == null) {
        return;
      }

      final requiredGroups = parameters.requiredGroups;

      // Check if all required groups are present
      final missingGroups =
          requiredGroups.where((groupName) => !groupDeclarations.contains(groupName)).toList();

      if (missingGroups.isNotEmpty) {
        final message = 'Missing required groups: ${missingGroups.join(', ')}';
        reporter.atNode(mainFunctionNode, code.copyWith(problemMessage: message));
      }
    });
  }

  @override
  List<Fix> getFixes() => [
        // Could implement fixes to add missing groups, but that's complex
        // For now, we'll just warn without providing fixes
      ];
}

class _MissingTestGroupOption extends CommonLintParameter {
  const _MissingTestGroupOption({
    super.excludes = const [],
    super.includes = const [],
    super.severity,
    this.requiredGroups = _defaultRequiredGroups,
  });

  final List<String> requiredGroups;

  static _MissingTestGroupOption fromMap(Map<String, dynamic> map) {
    return _MissingTestGroupOption(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
      requiredGroups:
          safeCastToListString(map['required_groups'], defaultValue: _defaultRequiredGroups),
    );
  }

  static const _defaultRequiredGroups = [
    'design',
    'others',
  ];
}
