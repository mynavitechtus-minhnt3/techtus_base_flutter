import 'package:collection/collection.dart';

import '../index.dart';

const _runCatchingFunction = 'runCatching';
const _viewModelClassNameRegex = r'^.+ViewModel$';

class MissingRunCatching extends OptionsLintRule<_MissingRunCatchingOption> {
  MissingRunCatching(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: lintName,
            configs: configs,
            paramsParser: _MissingRunCatchingOption.fromMap,
            problemMessage: (_) =>
                'All function called inside ViewModel classes must be wrapped with \'$_runCatchingFunction\' function.',
          ),
        );

  static const String lintName = 'missing_run_catching';

  @override
  Future<void> run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) async {
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

    context.registry.addMethodInvocation((node) {
      if (_addPrivateCase(parameters.startsWithPatterns).any(
            (element) => node.toString().startsWith(element),
          ) &&
          !_addPrivateCase(parameters.startsWithPatternsExcludes).any(
            (element) => node.toString().startsWith(element),
          ) &&
          RegExp(_viewModelClassNameRegex)
              .hasMatch(node.parentClassDeclaration?.name.toString() ?? '') &&
          !(node.realTarget?.staticType.toString().startsWith('Stream<') == true) &&
          node.thisOrAncestorMatching((astNode) {
                if (astNode is MethodInvocation) {
                  if (astNode.methodName.name == _runCatchingFunction) {
                    return true;
                  }
                }

                if (astNode is MethodDeclaration) {
                  final methodInvocations = astNode.pearMethodDeclarations
                      .map((e) => e.childMethodInvocations)
                      .firstWhereOrNull((element) {
                    final runBlocCatchingMethodInvocation = element.firstWhereOrNull(
                        (methodInvocation) =>
                            methodInvocation.methodName.name == _runCatchingFunction);

                    if (runBlocCatchingMethodInvocation == null) {
                      return false;
                    }

                    return runBlocCatchingMethodInvocation.childMethodInvocations.firstWhereOrNull(
                            (element) => element.methodName.name == astNode.name.toString()) !=
                        null;
                  });

                  if (methodInvocations != null) {
                    return true;
                  }
                }

                return false;
              }) ==
              null) {
        reporter.atNode(node, code);
      }
    });
  }

  List<String> _addPrivateCase(List<String> input) {
    final result = <String>{};

    for (final item in input) {
      result.add(item);
      result.add('_$item');
    }

    return result.toList();
  }
}

class _MissingRunCatchingOption extends Excludable {
  const _MissingRunCatchingOption({
    this.excludes = const [],
    this.includes = const [],
    this.severity,
    this.startsWithPatterns = _defaultStartsWithPatterns,
    this.startsWithPatternsExcludes = _defaultStartsWithPatternsExcludes,
  });

  final ErrorSeverity? severity;
  @override
  final List<String> excludes;
  @override
  final List<String> includes;
  final List<String> startsWithPatterns;
  final List<String> startsWithPatternsExcludes;

  static _MissingRunCatchingOption fromMap(Map<String, dynamic> map) {
    return _MissingRunCatchingOption(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
      startsWithPatterns: safeCastToListString(
        map['starts_with_patterns'],
        defaultValue: _defaultStartsWithPatterns,
      ),
      startsWithPatternsExcludes: safeCastToListString(
        map['starts_with_patterns_excludes'],
        defaultValue: _defaultStartsWithPatternsExcludes,
      ),
    );
  }

  static const _defaultStartsWithPatterns = ['ref.'];
  static const _defaultStartsWithPatternsExcludes = [
    'ref.nav.',
    'ref.update',
  ];
}
