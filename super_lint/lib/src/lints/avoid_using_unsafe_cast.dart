import '../index.dart';

class AvoidUsingUnsafeCast extends CommonLintRule<_AvoidUsingUnsafeCastParameter> {
  AvoidUsingUnsafeCast(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: 'avoid_using_unsafe_cast',
            configs: configs,
            paramsParser: _AvoidUsingUnsafeCastParameter.fromMap,
            problemMessage: (_) => 'Avoid using unsafe cast. Use \'safeCast\' function instead.',
          ),
        );

  @override
  Future<void> check(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
    String rootPath,
  ) async {
    context.registry.addAsExpression((node) {
      reporter.atToken(
        node.asOperator,
        code,
      );
    });
  }

  @override
  List<Fix> getFixes() {
    return [
      _AvoidUsingUnsafeCastFix(config),
    ];
  }
}

class _AvoidUsingUnsafeCastFix extends CommonQuickFix<_AvoidUsingUnsafeCastParameter> {
  _AvoidUsingUnsafeCastFix(super.config);

  @override
  Future<void> run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) async {
    context.registry.addAsExpression((node) {
      if (!node.sourceRange.intersects(analysisError.sourceRange)) {
        return;
      }

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with \'safeCast\' extension method',
        priority: 41,
      );

      changeBuilder.addDartFileEdit((builder) {
        final nonNullableType = node.type.toString().endsWith('?')
            ? node.type.toString().substring(0, node.type.length - 1)
            : node.type;
        if (node.expression.toString().startsWith('await')) {
          builder.addSimpleReplacement(
              node.sourceRange, '(${node.expression}).safeCast<$nonNullableType>()');
        } else {
          builder.addSimpleReplacement(
              node.sourceRange, '${node.expression}.safeCast<$nonNullableType>()');
        }
      });

      final changeBuilderCastFromDynamic = reporter.createChangeBuilder(
        message: 'Replace with \'safeCast\' function (use for dynamic type)',
        priority: 40,
      );

      changeBuilderCastFromDynamic.addDartFileEdit((builder) {
        final nonNullableType = node.type.toString().endsWith('?')
            ? node.type.toString().substring(0, node.type.length - 1)
            : node.type;
        if (node.expression.toString().startsWith('(') &&
            node.expression.toString().endsWith(')')) {
          builder.addSimpleReplacement(
              node.sourceRange, 'safeCast<$nonNullableType>${node.expression}');
        } else {
          builder.addSimpleReplacement(
              node.sourceRange, 'safeCast<$nonNullableType>(${node.expression})');
        }
      });
    });
  }
}

class _AvoidUsingUnsafeCastParameter extends CommonLintParameter {
  const _AvoidUsingUnsafeCastParameter({
    super.excludes,
    super.includes,
    super.severity,
  });

  static _AvoidUsingUnsafeCastParameter fromMap(Map<String, dynamic> map) {
    return _AvoidUsingUnsafeCastParameter(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
    );
  }
}
