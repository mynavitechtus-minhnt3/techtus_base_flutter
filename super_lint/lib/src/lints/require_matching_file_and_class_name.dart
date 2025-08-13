import 'package:path/path.dart' as p;

import '../index.dart';

class RequireMatchingFileAndClassName
    extends CommonLintRule<_RequireMatchingFileAndClassNameOption> {
  RequireMatchingFileAndClassName(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: 'require_matching_file_and_class_name',
            configs: configs,
            paramsParser: _RequireMatchingFileAndClassNameOption.fromMap,
            problemMessage: (_) => 'File name should match class name',
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

    if (classDecls.length == 1 && classDecls.first.name.lexeme != expectedClassName) {
      reporter.atNode(classDecls.first, code);
    }
  }

  static bool _isPublicClass(ClassDeclaration decl) {
    final name = decl.name.lexeme;
    return name.isNotEmpty && !name.startsWith('_') && decl.abstractKeyword == null;
  }
}

class _RequireMatchingFileAndClassNameOption extends CommonLintParameter {
  const _RequireMatchingFileAndClassNameOption({
    super.excludes,
    super.includes,
    super.severity,
  });

  static _RequireMatchingFileAndClassNameOption fromMap(Map<String, dynamic> map) {
    return _RequireMatchingFileAndClassNameOption(
      severity: safeCast(map['severity']),
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
    );
  }
}
