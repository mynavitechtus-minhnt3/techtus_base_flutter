import '../index.dart';

class IncorrectScreenNameEnumValue extends CommonLintRule<_IncorrectScreenNameEnumValueOption> {
  IncorrectScreenNameEnumValue(CustomLintConfigs configs)
      : super(
          RuleConfig(
            name: 'incorrect_screen_name_enum_value',
            configs: configs,
            paramsParser: _IncorrectScreenNameEnumValueOption.fromMap,
            problemMessage: (params) =>
                'The screenName, screenEventPrefix, or screenClass value does not follow the expected format.',
          ),
        );

  @override
  Future<void> check(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
    String rootPath,
  ) async {
    final code = this.code.copyWith(
          errorSeverity: parameters.severity ?? this.code.errorSeverity,
        );

    context.registry.addEnumDeclaration((enumNode) {
      if (enumNode.name.lexeme != 'ScreenName') return;

      for (final field in enumNode.constants) {
        final enumName = field.name.lexeme;

        for (final argument in field.arguments?.argumentList.arguments ?? []) {
          if (argument is NamedExpression) {
            final name = argument.name.label.name;
            final valueExpression = argument.expression;

            if (name == 'screenEventPrefix') {
              final value = _getStringLiteral(valueExpression);
              final expectedValue =
                  enumName.toSnakeCase().replaceLast(pattern: '_page', replacement: '');
              if (value != null && value != expectedValue) {
                reporter.atNode(
                  valueExpression,
                  code.copyWith(
                    problemMessage: '`screenEventPrefix` should be `$expectedValue`.',
                  ),
                );
              }
            }

            if (name == 'screenClass') {
              final value = _getStringLiteral(valueExpression);
              final expectedValue = enumName.toUpperFirstCase();
              if (value != null && value != expectedValue) {
                reporter.atNode(
                  valueExpression,
                  code.copyWith(
                    problemMessage: '`screenClass` should be `$expectedValue`.',
                  ),
                );
              }
            }
          }
        }
      }
    });
  }
}

class _IncorrectScreenNameEnumValueOption extends CommonLintParameter {
  const _IncorrectScreenNameEnumValueOption({
    super.excludes,
    super.includes,
    super.severity,
  });

  static _IncorrectScreenNameEnumValueOption fromMap(Map<String, dynamic> map) {
    return _IncorrectScreenNameEnumValueOption(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
    );
  }
}

String? _getStringLiteral(Expression expression) {
  if (expression is SimpleStringLiteral) {
    return expression.value;
  }
  return null;
}
