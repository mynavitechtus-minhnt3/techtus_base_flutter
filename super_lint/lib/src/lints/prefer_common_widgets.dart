import 'package:collection/collection.dart';

import '../index.dart';

class PreferCommonWidgets extends CommonLintRule<_PreferCommonWidgetsParameter> {
  PreferCommonWidgets(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: 'prefer_common_widgets',
            configs: configs,
            paramsParser: _PreferCommonWidgetsParameter.fromMap,
            problemMessage: (_) =>
                'Use Common Widgets(e.g. CommonText, CommonContainer,...) instead of built-in Widgets',
          ),
        );

  @override
  Future<void> check(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
    String rootPath,
  ) async {
    context.registry.addInstanceCreationExpression((node) {
      // Skip Text.rich - we only want to warn Text() but not Text.rich()
      if (node.constructorName.toString() == 'Text.rich') {
        return;
      }

      final bannedWidget = parameters.bannedWidgets.firstWhereOrNull((element) {
        final methodName = element[_PreferCommonWidgetsParameter.keyBannedWidget];
        return node.constructorName.type.toString() == methodName;
      });

      if (bannedWidget != null) {
        reporter.atNode(node.constructorName, code);
      }
    });
  }

  @override
  List<Fix> getFixes() => [
        _PreferCommonWidgetsFix(config),
      ];
}

class _PreferCommonWidgetsFix extends CommonQuickFix<_PreferCommonWidgetsParameter> {
  _PreferCommonWidgetsFix(super.config);

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

      final bannedWidget = parameters.bannedWidgets.firstWhereOrNull((element) {
        final methodName = element[_PreferCommonWidgetsParameter.keyBannedWidget];
        return node.constructorName.toString() == methodName;
      });

      if (bannedWidget == null) {
        return;
      }

      final commonWidget = bannedWidget[_PreferCommonWidgetsParameter.keyCommonWidget];

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with \'$commonWidget\'',
        priority: 7100,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(
          node.constructorName.sourceRange,
          commonWidget.toString(),
        );
      });
    });
  }
}

class _PreferCommonWidgetsParameter extends CommonLintParameter {
  const _PreferCommonWidgetsParameter({
    super.excludes,
    super.includes,
    super.severity,
    this.bannedWidgets = _defaultBannedWidgets,
  });

  final List<Map<String, String>> bannedWidgets;

  static _PreferCommonWidgetsParameter fromMap(Map<String, dynamic> map) {
    return _PreferCommonWidgetsParameter(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
      bannedWidgets: safeCastToListJson(map['banned_widgets'], defaultValue: _defaultBannedWidgets),
    );
  }

  static const _defaultBannedWidgets = [
    {
      keyBannedWidget: 'Text',
      keyCommonWidget: 'CommonText',
    },
    {
      keyBannedWidget: 'AppBar',
      keyCommonWidget: 'CommonAppBar',
    },
    {
      keyBannedWidget: 'Image',
      keyCommonWidget: 'CommonImage',
    },
    {
      keyBannedWidget: 'CachedNetworkImage',
      keyCommonWidget: 'CommonImage',
    },
    {
      keyBannedWidget: 'SvgPicture',
      keyCommonWidget: 'CommonImage',
    },
    {
      keyBannedWidget: 'Scaffold',
      keyCommonWidget: 'CommonScaffold',
    },
    {
      keyBannedWidget: 'Divider',
      keyCommonWidget: 'CommonDivider',
    },
    {
      keyBannedWidget: 'VerticalDivider',
      keyCommonWidget: 'CommonDivider',
    },
    {
      keyBannedWidget: 'RichText',
      keyCommonWidget: 'Text.rich',
    },
  ];

  static const keyBannedWidget = 'banned_widget';
  static const keyCommonWidget = 'common_widget';
}
