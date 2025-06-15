import '../index.dart';

class PreferNamedParameters extends OptionsLintRule<_PreferNamedParametersOption> {
  PreferNamedParameters(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
              name: 'prefer_named_parameters',
              configs: configs,
              paramsParser: _PreferNamedParametersOption.fromMap,
              problemMessage: (_) =>
                  'If a function or constructor takes more parameters than the threshold, use named parameters'),
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

    unawaited(resolver.getResolvedUnitResult().then((value) =>
        value.unit.visitChildren(ConstructorAndFunctionAndMethodDeclarationVisitor(
          onVisitFunctionDeclaration: (FunctionDeclaration node) {
            final formalParams =
                node.functionExpression.parameters?.parameters ?? <FormalParameter>[];
            if (formalParams.length >= parameters.threshold &&
                formalParams.where((element) => element.isNamed).length != formalParams.length) {
              reporter.atNode(node.functionExpression.parameters!, code);
            }
          },
          onVisitMethodDeclaration: (MethodDeclaration node) {
            final formalParams = node.parameters?.parameters ?? <FormalParameter>[];
            if (formalParams.length >= parameters.threshold &&
                !node.isOverrideMethod &&
                formalParams.where((element) => element.isNamed).length != formalParams.length) {
              reporter.atNode(node.parameters!, code);
            }
          },
          onVisitConstructorDeclaration: (ConstructorDeclaration node) {
            final formalParams = node.parameters.parameters;
            if (formalParams.length >= parameters.threshold &&
                !_isConstructorDeclarationException(node) &&
                formalParams.where((element) => element.isNamed).length != formalParams.length) {
              reporter.atNode(node.parameters, code);
            }
          },
        ))));
  }

  bool _isConstructorDeclarationException(ConstructorDeclaration node) {
    return node.name.toString() == 'fromJson' ||
        node.parentClassDeclaration?.toString().trim().startsWith(
                RegExp(r'@injectable|@lazySingleton|@singleton', caseSensitive: false)) ==
            true;
  }

  @override
  List<Fix> getFixes() => [
        _ConvertToNamedParameters(config),
      ];
}

class _ConvertToNamedParameters extends OptionsFix<_PreferNamedParametersOption> {
  _ConvertToNamedParameters(super.config);

  @override
  Future<void> run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) async {
    unawaited(resolver.getResolvedUnitResult().then((value) => value.unit.visitChildren(
            ConstructorAndFunctionAndMethodDeclarationVisitor(
                onVisitFunctionDeclaration: (FunctionDeclaration node) {
          if (node.functionExpression.parameters == null ||
              !node.functionExpression.parameters!.sourceRange
                  .intersects(analysisError.sourceRange)) {
            return;
          }

          _fix(parameterList: node.functionExpression.parameters!, reporter: reporter);
        }, onVisitMethodDeclaration: (MethodDeclaration node) {
          if (node.parameters == null ||
              !node.parameters!.sourceRange.intersects(analysisError.sourceRange)) {
            return;
          }

          _fix(parameterList: node.parameters!, reporter: reporter);
        }, onVisitConstructorDeclaration: (node) {
          if (!node.parameters.sourceRange.intersects(analysisError.sourceRange)) {
            return;
          }

          _fix(
            parameterList: node.parameters,
            reporter: reporter,
          );
        }))));
  }

  void _fix({
    required FormalParameterList parameterList,
    required ChangeReporter reporter,
  }) {
    final changeBuilder = reporter.createChangeBuilder(
      message: 'Convert to named parameters',
      priority: 76,
    );

    final parameters = parameterList.parameters
        .map((e) => e.declaredFragment?.element.type.isNullableType == true ||
                e.declaredFragment?.element.hasDefaultValue == true ||
                e.toString().trim().startsWith('required')
            ? e.toString()
            : 'required $e')
        .join(', ');

    changeBuilder.addDartFileEdit((builder) {
      builder.addSimpleReplacement(parameterList.sourceRange, '({$parameters,})');
      builder.formatWithPageWidth(parameterList.sourceRange);
    });
  }
}

class _PreferNamedParametersOption extends CommonLintOption {
  const _PreferNamedParametersOption({
    this.threshold = _defaultThreshold,
    super.excludes,
    super.includes,
    super.severity,
  });

  final int threshold;

  static _PreferNamedParametersOption fromMap(Map<String, dynamic> map) {
    return _PreferNamedParametersOption(
      threshold: safeCast(map['threshold']) ?? _defaultThreshold,
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
    );
  }

  static const _defaultThreshold = 2;
}
