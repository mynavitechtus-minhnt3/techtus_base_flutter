import '../index.dart';

class UtilFunctionsMustBeStatic extends OptionsLintRule<_UtilFunctionsMustBeStaticOption> {
  UtilFunctionsMustBeStatic(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: 'util_functions_must_be_static',
            configs: configs,
            paramsParser: _UtilFunctionsMustBeStaticOption.fromMap,
            problemMessage: (_) => 'Util functions must be declared as static functions.',
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

    context.registry.addFunctionDeclaration((node) {
      if (node.parent is CompilationUnit && !node.isPrivate && !node.isAnnotation) {
        reporter.atNode(
          node,
          code,
        );
      }
    });
  }

  @override
  List<Fix> getFixes() {
    return [ConvertToStaticFunction(config)];
  }
}

class ConvertToStaticFunction extends OptionsFix<_UtilFunctionsMustBeStaticOption> {
  ConvertToStaticFunction(super.config);

  @override
  Future<void> run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) async {
    context.registry.addFunctionDeclaration((node) {
      if (!node.sourceRange.intersects(analysisError.sourceRange) ||
          node.parent is! CompilationUnit ||
          node.isPrivate ||
          node.isAnnotation) {
        return;
      }

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Convert to static function',
        priority: 344,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(node.sourceRange,
            '''class ${convertSnakeCaseToPascalCase(getFileNameFromPath(resolver.path))} {
  static ${node.toSource()}
}
          ''');
      });
    });
  }
}

class _UtilFunctionsMustBeStaticOption extends CommonLintOption {
  const _UtilFunctionsMustBeStaticOption({
    super.excludes,
    super.includes,
    super.severity,
    this.utilsFolderPath = _defaultUtilsFolderPath,
  });

  final String utilsFolderPath;

  static _UtilFunctionsMustBeStaticOption fromMap(Map<String, dynamic> map) {
    final utilsFolderPath = safeCast<String>(map['utils_folder_path']) ?? _defaultUtilsFolderPath;
    final glob = '$utilsFolderPath/**';

    return _UtilFunctionsMustBeStaticOption(
      excludes: safeCastToListString(map['excludes']),
      includes: [...safeCastToListString(map['includes']), glob],
      severity: convertStringToErrorSeverity(map['severity']),
      utilsFolderPath: utilsFolderPath,
    );
  }

  static const _defaultUtilsFolderPath = 'lib/common/utils';
}
