import 'package:collection/collection.dart';

import '../index.dart';

class IncorrectEventParameterType extends OptionsLintRule<_IncorrectEventParameterTypeOption> {
  IncorrectEventParameterType(CustomLintConfigs configs)
      : super(
          RuleConfig(
            name: 'incorrect_event_parameter_type',
            configs: configs,
            paramsParser: _IncorrectEventParameterTypeOption.fromMap,
            problemMessage: (params) => 'Parameters must only allow String, int or double values.',
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

class _IncorrectEventParameterTypeOption extends CommonLintOption {
  const _IncorrectEventParameterTypeOption({
    super.excludes,
    super.includes,
    super.severity,
  });

  static _IncorrectEventParameterTypeOption fromMap(Map<String, dynamic> map) {
    return _IncorrectEventParameterTypeOption(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
    );
  }
}
