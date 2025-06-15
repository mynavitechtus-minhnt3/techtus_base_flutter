import 'package:collection/collection.dart';

import '../index.dart';

class MissingExpandedOrFlexible extends OptionsLintRule<_MissingExpandedOrFlexibleOption> {
  MissingExpandedOrFlexible(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: 'missing_expanded_or_flexible',
            configs: configs,
            paramsParser: _MissingExpandedOrFlexibleOption.fromMap,
            problemMessage: (options) =>
                'Should use Expanded or Flexible widget to avoid overflow error.',
          ),
        );


  @override
  Future<void> run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) async {
    final runCtx = await prepareRun(resolver);
    if (runCtx == null) return;
    final code = runCtx.code;
    final parameters = runCtx.parameters;

    context.registry.addInstanceCreationExpression((node) {
      final widget = node.constructorName.type.toString();
      if (widget == 'Row' || widget == 'Column') {
        final children = node.argumentList.arguments
            .whereType<NamedExpression>()
            .firstWhereOrNull((element) => element.name.label.name == 'children');

        if (children != null) {
          final childrenList = children.expression;
          if (childrenList is ListLiteral && childrenList.elements.length >= 2) {
            final children = childrenList.elements;
            final hasExpandedOrFlexible = children.any((element) {
              if (element is! InstanceCreationExpression) {
                return false;
              }
              final type = element.constructorName.type.toString();
              return type == 'Expanded' || type == 'Flexible';
            });

            if (!hasExpandedOrFlexible) {
              reporter.atNode(node.constructorName, code);
            }
          }
        }
      }
    });
  }
}

class _MissingExpandedOrFlexibleOption extends CommonLintOption {
  const _MissingExpandedOrFlexibleOption({
    super.excludes,
    super.includes,
    super.severity,
  });

  static _MissingExpandedOrFlexibleOption fromMap(Map<String, dynamic> map) {
    return _MissingExpandedOrFlexibleOption(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
    );
  }
}
