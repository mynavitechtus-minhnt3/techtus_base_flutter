import '../index.dart';

class UtilFunctionsMustBeStatic extends OptionsLintRule<_UtilFunctionsMustBeStaticOption> {
  UtilFunctionsMustBeStatic(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: lintName,
            configs: configs,
            paramsParser: _UtilFunctionsMustBeStaticOption.fromMap,
            problemMessage: (_) => 'Util functions must be declared as static functions.',
          ),
        );

  static const String lintName = 'util_functions_must_be_static';

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

class _UtilFunctionsMustBeStaticOption extends Excludable {
  const _UtilFunctionsMustBeStaticOption({
    this.excludes = const [],
    this.includes = const [],
    this.severity,
    this.utilsFolderPath = _defaultUtilsFolderPath,
  });

  final ErrorSeverity? severity;
  @override
  final List<String> excludes;
  @override
  final List<String> includes;
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
