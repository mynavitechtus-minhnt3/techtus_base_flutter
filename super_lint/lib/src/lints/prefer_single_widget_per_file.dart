import '../index.dart';

class PreferSingleWidgetPerFile extends CommonLintRule<_PreferSingleWidgetPerFileParameter> {
  PreferSingleWidgetPerFile(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: 'prefer_single_widget_per_file',
            configs: configs,
            paramsParser: _PreferSingleWidgetPerFileParameter.fromMap,
            problemMessage: (_) => 'Prefer single public widget per file',
          ),
        );

  @override
  Future<void> check(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
    String rootPath,
  ) async {
    final unit = (await resolver.getResolvedUnitResult()).unit;
    final classDecls = <ClassDeclaration>[];

    for (final declaration in unit.declarations) {
      if (declaration is ClassDeclaration && _isPublicClass(declaration)) {
        classDecls.add(declaration);
      }
    }

    if (classDecls.length > 1) {
      for (final classDecl in classDecls) {
        reporter.atNode(classDecl, code);
      }
    }
  }

  static bool _isPublicClass(ClassDeclaration decl) {
    final name = decl.name.lexeme;
    return name.isNotEmpty && !name.startsWith('_') && decl.abstractKeyword == null;
  }
}

class _PreferSingleWidgetPerFileParameter extends CommonLintParameter {
  const _PreferSingleWidgetPerFileParameter({
    super.excludes,
    super.includes,
    super.severity,
  });

  static _PreferSingleWidgetPerFileParameter fromMap(Map<String, dynamic> map) {
    return _PreferSingleWidgetPerFileParameter(
      severity: safeCast(map['severity']),
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
    );
  }
}
