import 'package:collection/collection.dart';

import '../index.dart';

const _testFunctionArgCount = 2;
const _regex = r'[A-Z]';

class PreferLowerCaseTestDescription extends CommonLintRule<_PreferLowerCaseTestDescriptionOption> {
  PreferLowerCaseTestDescription(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
              name: 'prefer_lower_case_test_description',
              configs: configs,
              paramsParser: _PreferLowerCaseTestDescriptionOption.fromMap,
              problemMessage: (_) =>
                  'Lower case the first character when writing tests descriptions.'),
        );

  @override
  Future<void> check(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
    String rootPath,
  ) async {
    context.registry.addMethodInvocation((node) {
      final testMethod = parameters.testMethods.firstWhereOrNull((element) {
        final methodName = element[_PreferLowerCaseTestDescriptionOption.keyMethodName];
        return node.methodName.name == methodName;
      });

      if (testMethod == null) {
        return;
      }

      final descriptionParamName = testMethod[_PreferLowerCaseTestDescriptionOption.keyParamName];

      if (node.argumentList.arguments.length >= _testFunctionArgCount) {
        final firstArgument = node.argumentList.arguments[0];
        if (firstArgument is StringLiteral &&
            firstArgument.stringValue?.isNotEmpty == true &&
            firstArgument.correspondingParameter?.displayName == descriptionParamName) {
          final firstCharacter = firstArgument.stringValue?[0];
          if (RegExp(_regex).hasMatch(firstCharacter ?? '')) {
            reporter.atNode(firstArgument, code);
          }
        }
      }
    });
  }

  @override
  List<Fix> getFixes() => [
        _ChangeToLowerCase(config),
      ];
}

class _ChangeToLowerCase extends CommonQuickFix<_PreferLowerCaseTestDescriptionOption> {
  _ChangeToLowerCase(super.config);

  @override
  Future<void> run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) async {
    context.registry.addMethodInvocation((node) {
      if (!node.sourceRange.intersects(analysisError.sourceRange) ||
          node.argumentList.arguments.length < _testFunctionArgCount) {
        return;
      }

      final testMethod = parameters.testMethods.firstWhereOrNull((element) {
        final methodName = element[_PreferLowerCaseTestDescriptionOption.keyMethodName];
        return node.methodName.name == methodName;
      });

      if (testMethod == null) {
        return;
      }

      final descriptionParamName = testMethod[_PreferLowerCaseTestDescriptionOption.keyParamName];

      final firstArgument = node.argumentList.arguments[0];
      if (firstArgument is StringLiteral &&
          firstArgument.stringValue?.isNotEmpty == true &&
          firstArgument.correspondingParameter?.displayName == descriptionParamName) {
        final firstCharacter = firstArgument.stringValue?[0];
        if (RegExp(_regex).hasMatch(firstCharacter ?? '')) {
          final changeBuilder = reporter.createChangeBuilder(
            message: 'Lower case the first character',
            priority: 1709,
          );

          changeBuilder.addDartFileEdit((builder) {
            builder.addSimpleReplacement(
              firstArgument.sourceRange,
              '\'${firstCharacter?.toLowerCase()}${firstArgument.stringValue?.substring(1)}\'',
            );
          });
        }
      }
    });
  }
}

class _PreferLowerCaseTestDescriptionOption extends CommonLintParameter {
  const _PreferLowerCaseTestDescriptionOption({
    super.excludes,
    super.includes,
    super.severity,
    this.testMethods = _defaultTestMethods,
  });

  final List<Map<String, String>> testMethods;

  static _PreferLowerCaseTestDescriptionOption fromMap(Map<String, dynamic> map) {
    return _PreferLowerCaseTestDescriptionOption(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
      testMethods: safeCastToListJson(map['test_methods'], defaultValue: _defaultTestMethods),
    );
  }

  static const _defaultTestMethods = [
    {
      keyMethodName: 'test',
      keyParamName: 'description',
    },
    {
      keyMethodName: 'stateNotifierTest',
      keyParamName: 'description',
    },
    {
      keyMethodName: 'testWidgets',
      keyParamName: 'description',
    },
    {
      keyMethodName: 'testGoldens',
      keyParamName: 'description',
    }
  ];

  static const keyMethodName = 'method_name';
  static const keyParamName = 'param_name';
}
