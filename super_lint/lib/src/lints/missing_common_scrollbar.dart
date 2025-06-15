import '../index.dart';

class MissingCommonScrollbar extends OptionsLintRule<_MissingCommonScrollbarOption> {
  MissingCommonScrollbar(
    CustomLintConfigs configs,
  ) : super(RuleConfig(
            name: lintName,
            configs: configs,
            paramsParser: _MissingCommonScrollbarOption.fromMap,
            problemMessage: (_) =>
                'Scrollable widgets in a Page class must be wrapped with CommonScrollbar.'));

  static const String lintName = 'missing_common_scrollbar';

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) async {
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

    context.registry.addInstanceCreationExpression((node) {
      if (config.parameters.scrollableWidgetNames.contains(node.staticType?.getDisplayString())) {
        final parentClassDeclaration = node.parentClassDeclaration;
        if (parentClassDeclaration != null &&
            parentClassDeclaration.name.toString().endsWith('Page') &&
            !parentClassDeclaration
                .toSource()
                .contains(config.parameters.commonScrollbarWidgetName)) {
          reporter.atNode(node.constructorName, code);
        }
      }
    });
  }

  @override
  List<Fix> getFixes() {
    return [_MissingCommonScrollbarFix(config)];
  }
}

class _MissingCommonScrollbarOption extends Excludable {
  const _MissingCommonScrollbarOption({
    this.excludes = const [],
    this.includes = const [],
    this.severity,
    this.commonScrollbarWidgetName = _defaultCommonScrollbarWidgetName,
    this.scrollableWidgetNames = _defaultScrollableWidgetNames,
  });

  final ErrorSeverity? severity;
  @override
  final List<String> excludes;
  @override
  final List<String> includes;
  final String commonScrollbarWidgetName;
  final List<String> scrollableWidgetNames;

  static _MissingCommonScrollbarOption fromMap(Map<String, dynamic> map) {
    return _MissingCommonScrollbarOption(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
      commonScrollbarWidgetName:
          map['common_scrollbar_widget_name'] as String? ?? _defaultCommonScrollbarWidgetName,
      scrollableWidgetNames: safeCastToListString(
        map['scrollable_widget_names'],
        defaultValue: _defaultScrollableWidgetNames,
      ),
    );
  }

  static const _defaultCommonScrollbarWidgetName = 'CommonScrollbarWithIosStatusBarTapDetector';
  static const _defaultScrollableWidgetNames = [
    'SingleChildScrollView',
    'ListView',
    'GridView',
    'NestedScrollView',
    'CustomScrollView',
    'CommonPagedGridView',
    'CommonPagedListView',
  ];
}

class _MissingCommonScrollbarFix extends OptionsFix<_MissingCommonScrollbarOption> {
  _MissingCommonScrollbarFix(super.config);

  @override
  Future<void> run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) async {
    context.registry.addInstanceCreationExpression((node) {
      if (!node.sourceRange.intersects(analysisError.sourceRange)) {
        return;
      }

      if (config.parameters.scrollableWidgetNames.contains(node.staticType?.getDisplayString())) {
        final parentClassDeclaration = node.parentClassDeclaration;
        if (parentClassDeclaration != null &&
            parentClassDeclaration.name.toString().endsWith('Page') &&
            !parentClassDeclaration
                .toSource()
                .contains(config.parameters.commonScrollbarWidgetName)) {
          final changeBuilder = reporter.createChangeBuilder(
            message: 'Wrap with ${config.parameters.commonScrollbarWidgetName}',
            priority: 7110,
          );

          changeBuilder.addDartFileEdit((builder) {
            builder.addSimpleReplacement(
              node.sourceRange,
              '${config.parameters.commonScrollbarWidgetName}(\n'
              '  routeName: ${_toRouteName(parentClassDeclaration.name.toString())},\n'
              '  controller: scrollController,\n'
              '  child: ${node.toSource()},\n'
              ')\n',
            );
            builder.formatWithPageWidth(node.sourceRange);
          });
        }
      }
    });
  }
}

String _toRouteName(String pageClassName) {
  final baseName = pageClassName.replaceFirst(RegExp(r'Page$'), 'Route');
  return '$baseName.name';
}
