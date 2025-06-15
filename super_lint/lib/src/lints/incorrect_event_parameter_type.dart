import 'package:collection/collection.dart';

import '../index.dart';

class IncorrectEventParameterType extends OptionsLintRule<_IncorrectEventParameterTypeOption> {
  IncorrectEventParameterType(CustomLintConfigs configs)
      : super(
          RuleConfig(
            name: lintName,
            configs: configs,
            paramsParser: _IncorrectEventParameterTypeOption.fromMap,
            problemMessage: (params) => 'Parameters must only allow String, int or double values.',
          ),
        );

  static const String lintName = 'incorrect_event_parameter_type';

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

    context.registry.addClassDeclaration((classNode) {
      final isAnalyticParameterSubclass =
          classNode.extendsClause?.superclass.type.toString() == 'AnalyticParameter';
      if (!isAnalyticParameterSubclass) return;

      final parametersGetter = classNode.members.firstWhereOrNull((member) {
        return member is MethodDeclaration && member.isGetter && member.name.lexeme == 'parameters';
      }) as MethodDeclaration?;

      if (parametersGetter == null) return;

      final getterBody = parametersGetter.body;
      if (getterBody is! ExpressionFunctionBody) return;

      final expression = getterBody.expression;

      if (expression is SetOrMapLiteral) {
        for (final entry in expression.elements) {
          if (entry is MapLiteralEntry) {
            final value = entry.value;
            final isValueValid = value.staticType?.isDartCoreString == true ||
                value.staticType?.isDartCoreInt == true ||
                value.staticType?.isDartCoreDouble == true;
            if (!isValueValid) {
              reporter.atNode(value, code);
            }
          }
        }
      }
    });
  }
}

class _IncorrectEventParameterTypeOption extends Excludable {
  const _IncorrectEventParameterTypeOption({
    this.excludes = const [],
    this.includes = const [],
    this.severity,
  });

  final ErrorSeverity? severity;
  @override
  final List<String> excludes;
  @override
  final List<String> includes;

  static _IncorrectEventParameterTypeOption fromMap(Map<String, dynamic> map) {
    return _IncorrectEventParameterTypeOption(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
    );
  }
}
