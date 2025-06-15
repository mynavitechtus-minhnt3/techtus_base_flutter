import '../index.dart';

class MissingCommonScrollbar extends OptionsLintRule<_MissingCommonScrollbarOption> {
  MissingCommonScrollbar(
    CustomLintConfigs configs,
  ) : super(RuleConfig(
            name: 'missing_common_scrollbar',
            configs: configs,
            paramsParser: _MissingCommonScrollbarOption.fromMap,
            problemMessage: (_) =>
                'Scrollable widgets in a Page class must be wrapped with CommonScrollbar.'));


  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) async {
    final runCtx = await prepareRun(resolver);
    if (runCtx == null) return;
    final code = runCtx.code;
    final parameters = runCtx.parameters;

    context.registry.addInstanceCreationExpression((node) {
      final widgetName = node.staticType?.getDisplayString();
      if (!config.parameters.scrollableWidgetNames.contains(widgetName)) {
        return;
      }

      final parentClassDeclaration = node.parentClassDeclaration;
      if (parentClassDeclaration == null ||
          !parentClassDeclaration.name.toString().endsWith('Page')) {
        return;
      }

      final isWrappedByCommonScrollbar = node.thisOrAncestorMatching((ancestor) {
            if (ancestor is InstanceCreationExpression) {
              final ancestorName = ancestor.constructorName.type.toString();
              return ancestorName == config.parameters.commonScrollbarWidgetName;
            }
            return false;
          }) !=
          null;
      final hasCommonScrollbarInClass =
          parentClassDeclaration.toSource().contains(config.parameters.commonScrollbarWidgetName);

      final hasController = node.argumentList.arguments
          .whereType<NamedExpression>()
          .any((arg) => arg.name.label.name == 'controller');

      if (!hasCommonScrollbarInClass) {
        reporter.atNode(node.constructorName, code);
        return;
      }

      if (isWrappedByCommonScrollbar && !hasController) {
        reporter.atNode(
            node.constructorName,
            code.copyWith(
              problemMessage:
                  'If ${node.constructorName} is wrapped by ${config.parameters.commonScrollbarWidgetName}, '
                  'it must have a \'ScrollController\' passed to it.',
            ));
      }
    });
  }

  @override
  List<Fix> getFixes() {
    return [_MissingCommonScrollbarFix(config)];
  }
}

class _MissingCommonScrollbarOption extends CommonLintOption {
  const _MissingCommonScrollbarOption({
    super.excludes,
    super.includes,
    super.severity,
    this.commonScrollbarWidgetName = _defaultCommonScrollbarWidgetName,
    this.scrollableWidgetNames = _defaultScrollableWidgetNames,
  });
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
