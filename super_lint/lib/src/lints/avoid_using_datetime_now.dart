import '../index.dart';

class AvoidUsingDateTimeNow extends CommonLintRule<_AvoidUsingDateTimeNowParameter> {
  AvoidUsingDateTimeNow(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: 'avoid_using_datetime_now',
            configs: configs,
            paramsParser: _AvoidUsingDateTimeNowParameter.fromMap,
            problemMessage: (_) =>
                "Avoid using DateTime.now() or DateTimeUtil.now in test widget files. Use DateTimeUtil.now for regular files.",
          ),
        );

  @override
  Future<void> check(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
    String rootPath,
  ) async {
    final filePath = resolver.path;
    final isTestWidgetFile =
        filePath.contains('test/widget_test/ui') && filePath.endsWith('_test.dart');

    // Check DateTime.now() for all files
    context.registry.addInstanceCreationExpression((node) {
      final type = node.constructorName.type.type;
      final name = node.constructorName.name?.name;

      if (type?.getDisplayString() == 'DateTime' && name == 'now') {
        reporter.atNode(node, code);
      }
    });

    // For test widget files, also check DateTimeUtil.now
    if (isTestWidgetFile) {
      context.registry.addPrefixedIdentifier((node) {
        final prefix = node.prefix.name;
        final identifier = node.identifier.name;
        if (prefix == 'DateTimeUtil' && identifier == 'now') {
          reporter.atNode(node, code);
        }
      });
    }
  }

  @override
  List<Fix> getFixes() => [
        _AvoidUsingDateTimeNowFix(config),
      ];
}

class _AvoidUsingDateTimeNowFix extends CommonQuickFix<_AvoidUsingDateTimeNowParameter> {
  _AvoidUsingDateTimeNowFix(super.config);

  @override
  Future<void> run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) async {
    final filePath = resolver.path;
    final isTestWidgetFile =
        filePath.contains('test/widget_test/ui') && filePath.endsWith('_test.dart');

    context.registry.addInstanceCreationExpression((node) {
      final sourceRange = node.sourceRange;
      if (!sourceRange.intersects(analysisError.sourceRange)) {
        return;
      }
      final type = node.constructorName.type.type;
      final name = node.constructorName.name?.name;
      if (type?.getDisplayString() == 'DateTime' && name == 'now') {
        final changeBuilder = reporter.createChangeBuilder(
          message: isTestWidgetFile
              ? "Replace with fixed 'DateTime()'"
              : "Replace with 'DateTimeUtil.now'",
          priority: 70,
        );
        changeBuilder.addDartFileEdit((builder) {
          if (isTestWidgetFile) {
            // For test widget files, suggest removing the usage
            builder.addSimpleReplacement(sourceRange, 'DateTime(2025, 8, 12)');
          } else {
            builder.addSimpleReplacement(sourceRange, 'DateTimeUtil.now');
          }
        });
      }
    });

    // Handle DateTimeUtil.now in test widget files
    if (isTestWidgetFile) {
      context.registry.addPrefixedIdentifier((node) {
        final sourceRange = node.sourceRange;
        if (!sourceRange.intersects(analysisError.sourceRange)) {
          return;
        }
        final prefix = node.prefix.name;
        final identifier = node.identifier.name;
        if (prefix == 'DateTimeUtil' && identifier == 'now') {
          final changeBuilder = reporter.createChangeBuilder(
            message: "Replace with fixed 'DateTime()'",
            priority: 70,
          );
          changeBuilder.addDartFileEdit((builder) {
            builder.addSimpleReplacement(sourceRange, 'DateTime(2025, 8, 12)');
          });
        }
      });
    }
  }
}

class _AvoidUsingDateTimeNowParameter extends CommonLintParameter {
  const _AvoidUsingDateTimeNowParameter({
    super.excludes,
    super.includes,
    super.severity,
  });

  static _AvoidUsingDateTimeNowParameter fromMap(Map<String, dynamic> map) {
    return _AvoidUsingDateTimeNowParameter(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
    );
  }
}
