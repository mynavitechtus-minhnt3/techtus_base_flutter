import '../index.dart';

const _className = 'EventConstants';

class IncorrectEventName extends CommonLintRule<_IncorrectEventNameParameter> {
  IncorrectEventName(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: 'incorrect_event_name',
            configs: configs,
            paramsParser: _IncorrectEventNameParameter.fromMap,
            problemMessage: (_) => 'Events in `$_className` must use snake_case naming.',
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
          if (initializer is! StringLiteral) continue; // Skip non-string literals

          final value = initializer.stringValue;
          if (value != null && !value.isSnakeCase) {
            reporter.atNode(initializer, code);
          }
        }
      }
    });
  }
}

class _IncorrectEventNameParameter extends CommonLintParameter {
  const _IncorrectEventNameParameter({
    super.excludes,
    super.includes,
    super.severity,
  });

  static _IncorrectEventNameParameter fromMap(Map<String, dynamic> map) {
    return _IncorrectEventNameParameter(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
    );
  }
}
