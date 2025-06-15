import '../index.dart';

class AvoidUsingUnsafeCast extends OptionsLintRule<_AvoidUsingUnsafeCastOption> {
  AvoidUsingUnsafeCast(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: 'avoid_using_unsafe_cast',
            configs: configs,
            paramsParser: _AvoidUsingUnsafeCastOption.fromMap,
            problemMessage: (_) => 'Avoid using unsafe cast. Use \'safeCast\' function instead.',
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
      ReplaceWithSafeCast(config),
    ];
  }
}

class ReplaceWithSafeCast extends OptionsFix<_AvoidUsingUnsafeCastOption> {
  ReplaceWithSafeCast(super.config);

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

class _AvoidUsingUnsafeCastOption extends CommonLintOption {
  const _AvoidUsingUnsafeCastOption({
    super.excludes,
    super.includes,
    super.severity,
  });

  static _AvoidUsingUnsafeCastOption fromMap(Map<String, dynamic> map) {
    return _AvoidUsingUnsafeCastOption(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
    );
  }
}
