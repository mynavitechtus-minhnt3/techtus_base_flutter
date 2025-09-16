import '../index.dart';

class InvalidTestGroupName extends CommonLintRule<_InvalidTestGroupNameOption> {
  InvalidTestGroupName(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
              name: lintName,
              configs: configs,
              paramsParser: _InvalidTestGroupNameOption.fromMap,
              problemMessage: (_) => 'Group name is not in the list of valid group names.'),
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

    final validGroupNames = parameters.validGroupNames;

    context.registry.addMethodInvocation((node) {
      if (node.methodName.name == 'group') {
        if (node.argumentList.arguments.isNotEmpty &&
            node.argumentList.arguments[0] is StringLiteral) {
          final groupName = (node.argumentList.arguments[0] as StringLiteral).stringValue;
          if (groupName != null && !validGroupNames.contains(groupName)) {
            final message =
                'Group name "$groupName" is not in the list of valid group names: ${validGroupNames.join(', ')}';
            reporter.atNode(node, code.copyWith(problemMessage: message));
          }
        }
      }
    });
  }
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
