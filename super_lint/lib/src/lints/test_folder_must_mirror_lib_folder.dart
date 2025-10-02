import 'package:collection/collection.dart';

import '../index.dart';

class TestFolderMustMirrorLibFolder
    extends CommonLintRule<_TestFolderMustMirrorLibFolderParameter> {
  TestFolderMustMirrorLibFolder(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: 'test_folder_must_mirror_lib_folder',
            configs: configs,
            paramsParser: _TestFolderMustMirrorLibFolderParameter.fromMap,
            problemMessage: (_) =>
                'Test files must be placed in allowed test folder paths and mirror the structure of the \'lib\' folder.',
          ),
        );

  static const _testFileSuffix = '_test';

  @override
  Future<void> check(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
    String rootPath,
  ) async {
    final relatedPath = relativePath(resolver.path, rootPath);

    final fileName = getFileNameFromPath(resolver.path);

    // Check if this is a test file
    if (!fileName.endsWith(_testFileSuffix)) {
      return;
    }

    // Check if file is in allowed test folder paths
    final testFolderPath =
        parameters.testFolderPaths.firstWhereOrNull((element) => relatedPath.startsWith(element));

    if (testFolderPath == null) {
      reporter.atOffset(
        offset: 0,
        length: resolver.documentLength,
        errorCode: code,
      );
      return;
    }

    final libFilePath = relatedPath
        .replaceFirst(testFolderPath, parameters.libFolderPath)
        .replaceLast(pattern: _testFileSuffix, replacement: '');

    // Check if the corresponding lib file exists
    final libFile = File('$rootPath/$libFilePath');
    if (!libFile.existsSync()) {
      reporter.atOffset(
        offset: 0,
        length: resolver.documentLength,
        errorCode: code,
      );
    }
  }
}

class _TestFolderMustMirrorLibFolderParameter extends CommonLintParameter {
  const _TestFolderMustMirrorLibFolderParameter({
    super.excludes,
    super.includes,
    super.severity,
    this.libFolderPath = _defaultLibFolderPath,
    this.testFolderPaths = _defaultTestFolderPaths,
  });
  final String libFolderPath;
  final List<String> testFolderPaths;

  static _TestFolderMustMirrorLibFolderParameter fromMap(Map<String, dynamic> map) {
    return _TestFolderMustMirrorLibFolderParameter(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
      libFolderPath: safeCast(map['lib_folder_path']) ?? _defaultLibFolderPath,
      testFolderPaths:
          safeCastToListString(map['test_folder_paths'], defaultValue: _defaultTestFolderPaths),
    );
  }

  static const _defaultLibFolderPath = 'lib';
  static const _defaultTestFolderPaths = ['test/unit_test', 'test/widget_test'];
}
