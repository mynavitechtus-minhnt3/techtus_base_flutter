import '../index.dart';

abstract class CommonLintRule<T extends CommonLintParameter> extends DartLintRule {
  CommonLintRule(this.config) : super(code: config.lintCode);
  final RuleConfig<T> config;

  T get parameters => config.parameters;

  @override
  Future<void> run(
      CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) async {
    final rootPath = await resolver.rootPath;
    if (parameters.shouldSkipAnalysis(
      path: resolver.path,
      rootPath: rootPath,
    )) {
      return;
    }

    check(resolver, reporter, context, rootPath);
  }

  Future<void> check(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
    String rootPath,
  );
}
