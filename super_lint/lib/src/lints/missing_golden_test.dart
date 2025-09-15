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

    // 1) For test files: warn if missing sibling folders
    if (relativeCurrentPath.startsWith('test/widget_test/') && currentPath.endsWith('_test.dart')) {
      final testDir = dirname(currentPath);
      final missing = <String>[];
      // Always require goldens for widget tests
      final goldensDir = Directory(join(testDir, 'goldens'));
      if (!goldensDir.existsSync()) missing.add('goldens');
      // Only require design folder for Page tests
      final isPageTest = relativeCurrentPath.contains('/ui/page/');
      if (isPageTest) {
        final designDir = Directory(join(testDir, 'design'));
        if (!designDir.existsSync()) missing.add('design');
      }

      if (missing.isNotEmpty) {
        context.registry.addCompilationUnit((node) {
          reporter.atOffset(
            offset: 0,
            length: resolver.documentLength,
            errorCode: code.copyWith(
              problemMessage: 'Missing required folder(s): ${missing.join(', ')}',
            ),
          );
        });
      }
      // For test files we don't need to continue to check lib->test mapping
      return;
    }

    // 2) For lib files: ensure a corresponding widget test exists under test/widget_test
    if (!relativeCurrentPath.startsWith('lib/') || !currentPath.endsWith('.dart')) {
      // Not in lib directory, skip
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

    // Calculate expected test file path
    final expectedTestPath = _calculateExpectedTestPath(currentPath, rootPath);

    // Check if test file exists
    final testFile = File(expectedTestPath);
    if (!testFile.existsSync()) {
      // Report missing golden test file
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
    // Convert from: lib/ui/page/login/login_page.dart
    // To: test/widget_test/ui/page/login/login_page_test.dart

    final relativePath = relative(currentPath, from: rootPath);
    final parts = relativePath.split('/');

    // Find the lib index
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

    // Build test path
    final testParts = <String>[];

    // Add parts before lib (e.g., apps/user_app or just the root if simple example)
    for (int i = 0; i < libIndex; i++) {
      testParts.add(parts[i]);
    }

    testParts.add('test/widget_test');

    // Add remaining path parts after lib
    for (int i = libIndex + 1; i < parts.length; i++) {
      if (i == parts.length - 1) {
        // Last part is the file, add _test before .dart
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
