import 'package:path/path.dart' as p;

import '../index.dart';

class PreferSingleWidgetPerFile extends OptionsLintRule<_PreferSingleWidgetPerFileOption> {
  PreferSingleWidgetPerFile(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: lintName,
            configs: configs,
            paramsParser: _PreferSingleWidgetPerFileOption.fromMap,
            problemMessage: (_) => 'Prefer single public widget per file',
          ),
        );

  static const String lintName = 'prefer_single_widget_per_file';

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) async {
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

class _PreferSingleWidgetPerFileOption extends Excludable {
  const _PreferSingleWidgetPerFileOption({
    this.excludes = const [],
    this.includes = const [],
    this.severity,
  });

  final ErrorSeverity? severity;

  @override
  final List<String> excludes;
  @override
  final List<String> includes;

  static _PreferSingleWidgetPerFileOption fromMap(Map<String, dynamic> map) {
    return _PreferSingleWidgetPerFileOption(
      severity: safeCast(map['severity']),
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
    );
  }
}
