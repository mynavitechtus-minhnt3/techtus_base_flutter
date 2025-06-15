import 'package:path/path.dart' as p;

import '../index.dart';

class PreferSingleWidgetPerFile extends CommonLintRule<_PreferSingleWidgetPerFileOption> {
  PreferSingleWidgetPerFile(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: 'prefer_single_widget_per_file',
            configs: configs,
            paramsParser: _PreferSingleWidgetPerFileOption.fromMap,
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
    final fileName = p.basenameWithoutExtension(resolver.path);
    final expectedClassName = fileName.snakeToPascal();
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
      return;
    }

    if (classDecls.length == 1 && classDecls.first.name.lexeme != expectedClassName) {
      reporter.atNode(classDecls.first, code);
    }
  }

  static bool _isPublicClass(ClassDeclaration decl) {
    final name = decl.name.lexeme;
    return name.isNotEmpty && !name.startsWith('_') && decl.abstractKeyword == null;
  }
}

class _PreferSingleWidgetPerFileOption extends CommonLintParameter {
  const _PreferSingleWidgetPerFileOption({
    super.excludes,
    super.includes,
    super.severity,
  });

  static _PreferSingleWidgetPerFileOption fromMap(Map<String, dynamic> map) {
    return _PreferSingleWidgetPerFileOption(
      severity: safeCast(map['severity']),
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
    );
  }
}
