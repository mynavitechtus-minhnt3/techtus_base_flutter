import '../index.dart';

class PreferImportingIndexFile extends CommonLintRule<_PreferImportingIndexFileOption> {
  PreferImportingIndexFile(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: 'prefer_importing_index_file',
            configs: configs,
            paramsParser: _PreferImportingIndexFileOption.fromMap,
            problemMessage: (options) =>
                'Should export these files to index.dart file and import index.dart file instead of importing each file separately.',
          ),
        );

  @override
  Future<void> check(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
    String rootPath,
  ) async {
    context.registry.addImportDirective((node) {
      final importUri = node.uri.stringValue;
      if (importUri != null &&
          !importUri.startsWith('dart:') &&
          !importUri.startsWith('package:') &&
          !importUri.endsWith('index.dart')) {
        reporter.atNode(node, code);
      }
    });
  }
}

class _PreferImportingIndexFileOption extends CommonLintParameter {
  const _PreferImportingIndexFileOption({
    super.excludes,
    super.includes,
    super.severity,
    this.classPostFixes = _defaultClassPostFixes,
    this.parentClassPreFixes = _defaultParentClassPreFixes,
  });

  final List<String> classPostFixes;
  final List<String> parentClassPreFixes;

  static _PreferImportingIndexFileOption fromMap(Map<String, dynamic> map) {
    return _PreferImportingIndexFileOption(
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
