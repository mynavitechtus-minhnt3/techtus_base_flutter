import '../index.dart';

class MissingGoldenTest extends CommonLintRule<_MissingGoldenTestOption> {
  MissingGoldenTest(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: 'missing_golden_test',
            configs: configs,
            paramsParser: _MissingGoldenTestOption.fromMap,
            problemMessage: (_) => 'Widget file is missing corresponding golden test file',
          ),
        );

  @override
  Future<void> check(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
    String rootPath,
  ) async {
    final currentPath = resolver.path;
    final relativeCurrentPath = relative(currentPath, from: rootPath);

    if (!relativeCurrentPath.startsWith('lib/') || !currentPath.endsWith('.dart')) {
      return;
    }

    bool isInWidgetFolder = false;
    for (final widgetFolder in parameters.widgetFolders) {
      if (relativeCurrentPath.startsWith(widgetFolder)) {
        isInWidgetFolder = true;
        break;
      }
    }

    if (!isInWidgetFolder) {
      return;
    }

    final expectedTestPath = _calculateExpectedTestPath(currentPath, rootPath);
    final testFile = File(expectedTestPath);
    if (!testFile.existsSync()) {
      context.registry.addCompilationUnit((node) {
        reporter.atOffset(
          offset: 0,
          length: resolver.documentLength,
          errorCode: code,
        );
      });
    }
  }

  String _calculateExpectedTestPath(String currentPath, String rootPath) {
    final relativePath = relative(currentPath, from: rootPath);
    final parts = relativePath.split('/');

    int libIndex = -1;

    for (int i = 0; i < parts.length; i++) {
      if (parts[i] == 'lib') {
        libIndex = i;
        break;
      }
    }

    if (libIndex == -1) {
      return '';
    }

    final testParts = <String>[];

    for (int i = 0; i < libIndex; i++) {
      testParts.add(parts[i]);
    }

    testParts.add(parameters.testFolder);

    for (int i = libIndex + 1; i < parts.length; i++) {
      if (i == parts.length - 1) {
        final fileName = parts[i];
        final nameWithoutExtension = fileName.replaceFirst('.dart', '');
        testParts.add('${nameWithoutExtension}_test.dart');
      } else {
        testParts.add(parts[i]);
      }
    }

    return join(rootPath, testParts.join('/'));
  }
}

class _MissingGoldenTestOption extends CommonLintParameter {
  const _MissingGoldenTestOption({
    super.excludes,
    super.includes,
    super.severity,
    this.widgetFolders = const [],
    this.testFolder = _defaultWidgetFolder,
  });

  final List<String> widgetFolders;
  final String testFolder;

  static const String _defaultWidgetFolder = 'test/widget_test';

  static _MissingGoldenTestOption fromMap(Map<String, dynamic> map) {
    return _MissingGoldenTestOption(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
      widgetFolders: safeCastToListString(map['widget_folders']),
      testFolder: safeCast(map['test_folder']) ?? _defaultWidgetFolder,
    );
  }
}
