import '../index.dart';

class InvalidTestGroupName extends CommonLintRule<_InvalidTestGroupNameOption> {
  InvalidTestGroupName(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
              name: lintName,
              configs: configs,
              paramsParser: _InvalidTestGroupNameOption.fromMap,
              problemMessage: (_) =>
                  'Test files must declare all required group names and use only allowed names.'),
        );

  static const String lintName = 'invalid_test_group_name';

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

      final validGroupNames = parameters.validGroupNames;

      // Check if all required groups are present
      final missingGroups =
          validGroupNames.where((groupName) => !groupDeclarations.contains(groupName)).toList();

      // Check if all declared groups are valid
      final invalidGroups =
          groupDeclarations.where((groupName) => !validGroupNames.contains(groupName)).toList();

      if (missingGroups.isNotEmpty || invalidGroups.isNotEmpty) {
        final messages = <String>[];

        if (missingGroups.isNotEmpty) {
          messages.add('Missing required groups: ${missingGroups.join(', ')}');
        }

        if (invalidGroups.isNotEmpty) {
          messages.add('Invalid group names found: ${invalidGroups.join(', ')}');
        }

        reporter.atNode(mainFunctionNode, code.copyWith(problemMessage: messages.join('. ')));
      }
    });
  }

  @override
  List<Fix> getFixes() => [
        // Could implement fixes to add missing groups, but that's complex
        // For now, we'll just warn without providing fixes
      ];
}

class _InvalidTestGroupNameOption extends CommonLintParameter {
  const _InvalidTestGroupNameOption({
    super.excludes = const [],
    super.includes = const [],
    super.severity,
    this.validGroupNames = _defaultValidGroupNames,
  });

  final List<String> validGroupNames;

  static _InvalidTestGroupNameOption fromMap(Map<String, dynamic> map) {
    return _InvalidTestGroupNameOption(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
      validGroupNames:
          safeCastToListString(map['valid_group_names'], defaultValue: _defaultValidGroupNames),
    );
  }

  static const _defaultValidGroupNames = [
    'design',
    'others',
  ];
}
