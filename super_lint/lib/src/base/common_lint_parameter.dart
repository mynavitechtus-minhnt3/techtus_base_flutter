import '../index.dart';

abstract class CommonLintParameter {
  const CommonLintParameter({
    this.excludes = const [],
    this.includes = const [],
    this.severity,
  });

  final List<String> excludes;
  final List<String> includes;
  final ErrorSeverity? severity;

  bool shouldSkipAnalysis({
    required String path,
    required String rootPath,
  }) {
    return shouldSkipFile(
      includeGlobs: includes,
      excludeGlobs: excludes,
      path: path,
      rootPath: rootPath,
    );
  }
}
