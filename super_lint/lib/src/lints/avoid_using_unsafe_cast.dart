import '../index.dart';

class AvoidUsingUnsafeCast extends OptionsLintRule<_AvoidUsingUnsafeCastOption> {
  AvoidUsingUnsafeCast(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: lintName,
            configs: configs,
            paramsParser: _AvoidUsingUnsafeCastOption.fromMap,
            problemMessage: (_) => 'Avoid using unsafe cast. Use \'safeCast\' function instead.',
          ),
        );

  static const String lintName = 'avoid_using_unsafe_cast';

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

class _AvoidUsingUnsafeCastOption extends Excludable {
  const _AvoidUsingUnsafeCastOption({
    this.excludes = const [],
    this.includes = const [],
    this.severity,
  });

  final ErrorSeverity? severity;
  @override
  final List<String> excludes;
  @override
  final List<String> includes;

  static _AvoidUsingUnsafeCastOption fromMap(Map<String, dynamic> map) {
    return _AvoidUsingUnsafeCastOption(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
    );
  }
}
