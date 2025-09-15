import 'package:collection/collection.dart';

import '../index.dart';

class IncorrectGoldenImageName extends CommonLintRule<_IncorrectGoldenImageNameOption> {
  IncorrectGoldenImageName(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: lintName,
            configs: configs,
            paramsParser: _IncorrectGoldenImageNameOption.fromMap,
            problemMessage: (_) =>
                'Golden image filename must start with page name and equal the test description',
          ),
        );

  static const String lintName = 'incorrect_golden_image_name';

  @override
  Future<void> check(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
    String rootPath,
  ) async {
    final code = this.code.copyWith(
          errorSeverity: parameters.severity ?? this.code.errorSeverity,
        );

    // Only process test files
    if (!resolver.path.endsWith('_test.dart')) {
      return;
    }

    // Extract page name from test file path
    final fileName = basenameWithoutExtension(resolver.path);
    final pageName = fileName.replaceFirst('_test', '');

    context.registry.addMethodInvocation((node) {
      // Check if this is a testWidget method call inside testGoldens
      if (node.methodName.name != 'testWidget') {
        return;
      }

      // Find the parent testGoldens call to get the test description
      AstNode? current = node.parent;
      String? testDescription;

      while (current != null) {
        if (current is MethodInvocation && current.methodName.name == 'testGoldens') {
          // Get the first argument which is the test description
          if (current.argumentList.arguments.isNotEmpty) {
            final firstArg = current.argumentList.arguments[0];
            if (firstArg is StringLiteral) {
              testDescription = firstArg.stringValue;
            }
          }
          break;
        }
        current = current.parent;
      }

      if (testDescription == null) {
        return;
      }

      // Find the filename argument in testWidget call
      final filenameArg = node.argumentList.arguments
          .whereType<NamedExpression>()
          .firstWhereOrNull((arg) => arg.name.label.name == 'filename');

      if (filenameArg?.expression is! StringLiteral) {
        return;
      }

      final filenameExpression = filenameArg!.expression as StringLiteral;
      final filenameValue = filenameExpression.stringValue;

      if (filenameValue == null) {
        return;
      }

      // Check Rule 1: filename must start with page name
      if (!filenameValue.startsWith('$pageName/')) {
        reporter.atNode(
          filenameExpression,
          code.copyWith(
            problemMessage:
                'Golden image filename must start with "$pageName/" (from test file name)',
          ),
        );
        return;
      }

      // Check Rule 2: the part after "$pageName/" must equal the test description
      final expected = '$pageName/$testDescription';
      if (filenameValue != expected) {
        reporter.atNode(
          filenameExpression,
          code.copyWith(
            problemMessage: 'Golden image filename must equal "$expected" (page/test description)',
          ),
        );
      }
    });
  }

  @override
  List<Fix> getFixes() => [
        _IncorrectGoldenImageNameFix(config),
      ];
}

class _IncorrectGoldenImageNameFix extends CommonQuickFix<_IncorrectGoldenImageNameOption> {
  _IncorrectGoldenImageNameFix(super.config);

  @override
  Future<void> run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) async {
    // Only handle in test files
    if (!resolver.path.endsWith('_test.dart')) return;

    final fileName = basenameWithoutExtension(resolver.path);
    final pageName = fileName.replaceFirst('_test', '');

    context.registry.addMethodInvocation((node) {
      // Only handle testWidget calls
      if (node.methodName.name != 'testWidget') return;

      // Ensure the reported error is on this node's filename argument
      final filenameArg = node.argumentList.arguments
          .whereType<NamedExpression>()
          .firstWhereOrNull((a) => a.name.label.name == 'filename');
      if (filenameArg == null) return;

      final expr = filenameArg.expression;
      if (expr is! StringLiteral) return;

      if (!expr.sourceRange.intersects(analysisError.sourceRange)) return;

      // Locate the surrounding testGoldens to grab description
      AstNode? current = node.parent;
      String? testDescription;
      while (current != null) {
        if (current is MethodInvocation && current.methodName.name == 'testGoldens') {
          if (current.argumentList.arguments.isNotEmpty) {
            final firstArg = current.argumentList.arguments[0];
            if (firstArg is StringLiteral) {
              testDescription = firstArg.stringValue;
            }
          }
          break;
        }
        current = current.parent;
      }
      if (testDescription == null) return;

      final expected = "$pageName/$testDescription";

      final changeBuilder = reporter.createChangeBuilder(
        message: "Set filename to '$expected'",
        priority: 70,
      );
      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(expr.sourceRange, "'$expected'");
      });
    });
  }
}

class _IncorrectGoldenImageNameOption extends CommonLintParameter {
  const _IncorrectGoldenImageNameOption({
    super.excludes = const [],
    super.includes = const [],
    super.severity,
  });

  static _IncorrectGoldenImageNameOption fromMap(Map<String, dynamic> map) {
    return _IncorrectGoldenImageNameOption(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
    );
  }
}
