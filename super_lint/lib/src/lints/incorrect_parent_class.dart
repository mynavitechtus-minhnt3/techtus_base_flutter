import '../index.dart';

class IncorrectParentClass extends CommonLintRule<_IncorrectParentClassParameter> {
  IncorrectParentClass(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: 'incorrect_parent_class',
            configs: configs,
            paramsParser: _IncorrectParentClassParameter.fromMap,
            problemMessage: (options) =>
                'Page classes must extend ${options.parentClassPreFixes.join(' or ')}',
          ),
        );

  @override
  Future<void> check(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
    String rootPath,
  ) async {
    context.registry.addClassDeclaration((node) {
      final parent = node.extendsClause?.superclass;
      final currentClass = node.name.toString();
      if (parent != null) {
        final parentName = parent.toString();
        if (parameters.classPostFixes.any((e) => currentClass.endsWith(e)) &&
            !parameters.parentClassPreFixes.any((e) => parentName.startsWith(e))) {
          reporter.atNode(
            node,
            code,
          );
        }
      }
    });
  }
}

class _IncorrectParentClassParameter extends CommonLintParameter {
  const _IncorrectParentClassParameter({
    super.excludes,
    super.includes,
    super.severity,
    this.classPostFixes = _defaultClassPostFixes,
    this.parentClassPreFixes = _defaultParentClassPreFixes,
  });

  final List<String> classPostFixes;
  final List<String> parentClassPreFixes;

  static _IncorrectParentClassParameter fromMap(Map<String, dynamic> map) {
    return _IncorrectParentClassParameter(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
      classPostFixes:
          safeCastToListString(map['class_post_fixes'], defaultValue: _defaultClassPostFixes),
      parentClassPreFixes: safeCastToListString(map['parent_class_pre_fixes'],
          defaultValue: _defaultParentClassPreFixes),
    );
  }

  static const _defaultClassPostFixes = ['Page', 'PageState'];
  static const _defaultParentClassPreFixes = [
    'BasePage',
    'BaseStatefulPageState',
    'StatefulHookConsumerWidget',
  ];
}
