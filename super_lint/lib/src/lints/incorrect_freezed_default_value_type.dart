import 'package:collection/collection.dart';

import '../index.dart';

class IncorrectFreezedDefaultValueType extends OptionsLintRule<_IncorrectFreezedDefaultValueTypeOption> {
  IncorrectFreezedDefaultValueType(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: 'incorrect_freezed_default_value_type',
            configs: configs,
            paramsParser: _IncorrectFreezedDefaultValueTypeOption.fromMap,
            problemMessage: (_) => 'The value used in @Default must match the field type.',
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

    final resolvedUnit = await resolver.getResolvedUnitResult();
    final typeSystem = resolvedUnit.typeSystem;

    context.registry.addSimpleFormalParameter((node) {
      final annotation = node.metadata.firstWhereOrNull((element) {
        if (element.name.name != 'Default') return false;
        final libraryUri = element.element2?.library2?.uri.toString();
        return libraryUri?.contains('freezed_annotation') == true;
      });

      if (annotation == null) return;

      final argList = annotation.arguments?.arguments;
      final defaultArg = argList != null && argList.isNotEmpty ? argList.first : null;
      if (defaultArg == null) return;

      final defaultType = defaultArg.staticType;
      final paramType = node.declaredFragment?.element.type;
      if (defaultType == null || paramType == null) return;

      if (!typeSystem.isAssignableTo(defaultType, paramType)) {
        reporter.atNode(annotation, code);
      }
    });
  }
}

class _IncorrectFreezedDefaultValueTypeOption extends CommonLintOption {
  const _IncorrectFreezedDefaultValueTypeOption({
    super.excludes,
    super.includes,
    super.severity,
  });

  static _IncorrectFreezedDefaultValueTypeOption fromMap(Map<String, dynamic> map) {
    return _IncorrectFreezedDefaultValueTypeOption(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
    );
  }
}
