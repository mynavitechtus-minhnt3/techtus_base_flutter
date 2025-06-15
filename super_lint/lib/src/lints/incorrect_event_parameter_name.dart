import '../index.dart';

const _className = 'ParameterConstants';

class IncorrectEventParameterName extends CommonLintRule<_IncorrectEventParameterNameOption> {
  IncorrectEventParameterName(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: 'incorrect_event_parameter_name',
            configs: configs,
            paramsParser: _IncorrectEventParameterNameOption.fromMap,
            problemMessage: (options) => 'Parameters in `$_className` must use snake_case naming.',
          ),
        );

  @override
  Future<void> check(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
    String rootPath,
  ) async {
    context.registry.addClassDeclaration((node) {
      final className = node.name.lexeme;
      if (className != _className) return;

      final constantFields = node.members.whereType<FieldDeclaration>().where((field) {
        return field.isStatic && field.fields.isConst;
      });

      for (final field in constantFields) {
        for (final variable in field.fields.variables) {
          final initializer = variable.initializer;
          if (initializer is! StringLiteral) continue;

          final value = initializer.stringValue;
          if (value != null && !value.isSnakeCase) {
            reporter.atNode(initializer, code);
          }
        }
      }
    });
  }
}

class _IncorrectEventParameterNameOption extends CommonLintParameter {
  const _IncorrectEventParameterNameOption({
    super.excludes,
    super.includes,
    super.severity,
  });

  static _IncorrectEventParameterNameOption fromMap(Map<String, dynamic> map) {
    return _IncorrectEventParameterNameOption(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
    );
  }
}
