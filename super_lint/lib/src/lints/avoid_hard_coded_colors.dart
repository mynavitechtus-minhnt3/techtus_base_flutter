import '../index.dart';

class AvoidHardCodedColors extends CommonLintRule<_AvoidHardCodedColorsOption> {
  AvoidHardCodedColors(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
              name: 'avoid_hard_coded_colors',
              configs: configs,
              paramsParser: _AvoidHardCodedColorsOption.fromMap,
              problemMessage: (_) =>
                  'Avoid hard-coding colors, except for Colors.transparent, such as Color(0xFFFFFF) and Colors.white.\nPlease use \'cl.xxx\' instead'),
        );

  @override
  Future<void> check(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
    String rootPath,
  ) async {
    unawaited(resolver
        .getResolvedUnitResult()
        .then((value) => value.unit.visitChildren(VariableAndArgumentVisitor(
              onVisitInstanceCreationExpression: (InstanceCreationExpression node) {
                for (var element in node.argumentList.arguments) {
                  if (element is NamedExpression) {
                    if (_isHardCoded(element.expression.toString())) {
                      reporter.atNode(element.expression, code);
                    }
                  } else if (_isHardCoded(element.toString())) {
                    reporter.atNode(element, code);
                  }
                }
              },
              onVisitVariableDeclaration: (VariableDeclaration node) {
                if (node.initializer != null && _isHardCoded(node.initializer.toString())) {
                  reporter.atNode(node.initializer!, code);
                }
              },
              onVisitAssignmentExpression: (AssignmentExpression node) {
                if (_isHardCoded(node.rightHandSide.toString())) {
                  reporter.atNode(node.rightHandSide, code);
                }
              },
              onVisitConstructorFieldInitializer: (ConstructorFieldInitializer node) {
                if (_isHardCoded(node.expression.toString())) {
                  reporter.atNode(node.expression, code);
                }
              },
              onVisitSuperConstructorInvocation: (SuperConstructorInvocation node) {
                for (var element in node.argumentList.arguments) {
                  if (element is NamedExpression) {
                    if (_isHardCoded(element.expression.toString())) {
                      reporter.atNode(element.expression, code);
                    }
                  } else if (_isHardCoded(element.toString())) {
                    reporter.atNode(element, code);
                  }
                }
              },
              onVisitConstructorDeclaration: (ConstructorDeclaration node) {
                for (var element in node.parameters.parameterFragments) {
                  if (element?.element.defaultValueCode != null &&
                      _isHardCoded(element!.element.defaultValueCode!)) {
                    if (element is DefaultFieldFormalParameterElementImpl) {
                      reporter.atNode(element.constantInitializer!, code);
                    } else if (element is DefaultParameterElementImpl) {
                      reporter.atNode(element.constantInitializer!, code);
                    } else {
                      reporter.atNode(node, code);
                    }
                  }
                }
              },
              onVisitArgumentList: (node) {
                for (var element in node.arguments) {
                  if (element is NamedExpression) {
                    if (_isHardCoded(element.expression.toString())) {
                      reporter.atNode(element.expression, code);
                    }
                  } else if (_isHardCoded(element.toString())) {
                    reporter.atNode(element, code);
                  }
                }
              },
            ))));
  }

  bool _isHardCoded(String color) {
    if (color == 'Colors.transparent') {
      return false;
    }

    if (color.replaceAll(' ', '').startsWith('Color(') ||
        color.replaceAll(' ', '').startsWith('Colors.') ||
        color.replaceAll(' ', '').startsWith('Color.')) {
      return true;
    }

    return false;
  }
}

class _AvoidHardCodedColorsOption extends CommonLintParameter {
  const _AvoidHardCodedColorsOption({
    super.excludes,
    super.includes,
    super.severity,
  });

  static _AvoidHardCodedColorsOption fromMap(Map<String, dynamic> map) {
    return _AvoidHardCodedColorsOption(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
    );
  }
}
