import '../index.dart';

const _className = 'EventConstants';

class IncorrectEventName extends OptionsLintRule<_IncorrectEventNameOption> {
  IncorrectEventName(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: lintName,
            configs: configs,
            paramsParser: _IncorrectEventNameOption.fromMap,
            problemMessage: (options) => 'Events in `$_className` must use snake_case naming.',
          ),
        );

  static const String lintName = 'incorrect_event_name';

  @override
  Future<void> run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) async {
    final rootPath = await resolver.rootPath;
    final parameters = config.parameters;

    if (parameters.shouldSkipAnalysis(
      path: resolver.path,
      rootPath: rootPath,
    )) {
      return;
    }

    final code = this.code.copyWith(
          errorSeverity: parameters.severity ?? this.code.errorSeverity,
        );

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

class _IncorrectEventNameOption extends Excludable {
  const _IncorrectEventNameOption({
    this.excludes = const [],
    this.includes = const [],
    this.severity,
  });

  final ErrorSeverity? severity;
  @override
  final List<String> excludes;
  @override
  final List<String> includes;

  static _IncorrectEventNameOption fromMap(Map<String, dynamic> map) {
    return _IncorrectEventNameOption(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
    );
  }
}
