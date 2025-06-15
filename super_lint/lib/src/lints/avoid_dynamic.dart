import '../index.dart';

class AvoidDynamic extends CommonLintRule<_AvoidDynamicParameter> {
  AvoidDynamic(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: 'avoid_dynamic',
            configs: configs,
            paramsParser: _AvoidDynamicParameter.fromMap,
            problemMessage: (_) => 'Avoid using dynamic type.',
          ),
        );

  @override
  Future<void> check(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
    String rootPath,
  ) async {
    context.registry.addNamedType((node) {
      if (node.type is! DynamicType) return;

      if (_isNodeUsedInMap(node)) return;

      reporter.atNode(node, code);
    });
  }

  bool _isNodeUsedInMap(AstNode node) {
    final parent = node.parent;
    final grandParent = parent?.parent;

    if (parent is! TypeArgumentList) return false;

    if ((grandParent is NamedType && grandParent.type?.isDartCoreMap == true) ||
        (grandParent is SetOrMapLiteral && grandParent.isMap)) {
      return true;
    }

    return false;
  }
}

class _AvoidDynamicParameter extends CommonLintParameter {
  const _AvoidDynamicParameter({
    super.excludes,
    super.includes,
    super.severity,
  });

  static _AvoidDynamicParameter fromMap(Map<String, dynamic> map) {
    return _AvoidDynamicParameter(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
    );
  }
}
