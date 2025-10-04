import '../index.dart';

class AvoidUsingEnumNameAsKey extends CommonLintRule<_AvoidUsingEnumNameAsKeyParameter> {
  AvoidUsingEnumNameAsKey(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: 'avoid_using_enum_name_as_key',
            configs: configs,
            paramsParser: _AvoidUsingEnumNameAsKeyParameter.fromMap,
            problemMessage: (_) =>
                'Avoid using enum names as keys. Use string constants instead to prevent data loss during refactoring.',
          ),
        );

  @override
  Future<void> check(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
    String rootPath,
  ) async {
    context.registry.addMethodInvocation((node) {
      _checkMethodInvocation(node, reporter);
    });
  }

  void _checkMethodInvocation(MethodInvocation node, ErrorReporter reporter) {
    // Check if this is a SharedPreferences method call from AppPreferences
    if (_isSharedPreferencesMethod(node) && _isAppPreferencesCall(node)) {
      _checkArgumentsForEnumUsage(node.argumentList.arguments, node, reporter);
    }
  }

  bool _isSharedPreferencesMethod(MethodInvocation node) {
    final methodName = node.methodName.name;
    final sharedPreferencesMethods = {
      'getString',
      'getStringList',
      'getInt',
      'getDouble',
      'getBool',
      'setString',
      'setStringList',
      'setInt',
      'setDouble',
      'setBool',
      'remove',
      'containsKey',
    };

    return sharedPreferencesMethods.contains(methodName);
  }

  bool _isAppPreferencesCall(MethodInvocation node) {
    // Check if the target is a SharedPreferences instance
    final target = node.target;
    if (target is Identifier) {
      // Check if the variable name suggests it's from AppPreferences
      final targetName = target.name.toLowerCase();
      return targetName.contains('prefs') ||
          targetName.contains('preference') ||
          targetName.contains('storage');
    }
    return true; // Default to true if we can't determine the caller type
  }

  void _checkArgumentsForEnumUsage(
      List<Expression> arguments, AstNode node, ErrorReporter reporter) {
    if (arguments.isEmpty) return;
    _checkExpressionForEnumUsage(arguments.first, node, reporter);
  }

  void _checkExpressionForEnumUsage(Expression expression, AstNode node, ErrorReporter reporter) {
    if (expression is PropertyAccess) {
      _checkPropertyAccessForEnum(expression, node, reporter);
    } else if (expression is PrefixedIdentifier) {
      if (expression.element.toString() == 'String get name' &&
          expression.name.contains('.name') &&
          expression.prefix.staticType?.isEnum == true) {
        reporter.atNode(expression, code);
      }
    }
  }

  void _checkPropertyAccessForEnum(PropertyAccess node, AstNode parent, ErrorReporter reporter) {
    // Check if this is accessing .name property
    if (node.propertyName.name == 'name') {
      final target = node.target;

      // Check if target is an enum or enum value
      bool isEnum = false;

      if (target is Identifier) {
        // Direct enum reference like MyEnum.someValue.name
        isEnum = target.staticType?.isEnum ?? false;
      } else if (target is PropertyAccess) {
        // Enum value access like MyEnum.someValue.name
        final targetType = target.staticType;
        isEnum = targetType?.isEnum ?? false;
      }

      if (isEnum) {
        reporter.atNode(node, code);
      }
    }
  }
}

class _AvoidUsingEnumNameAsKeyParameter extends CommonLintParameter {
  const _AvoidUsingEnumNameAsKeyParameter({
    super.excludes,
    super.includes,
    super.severity,
  });

  static _AvoidUsingEnumNameAsKeyParameter fromMap(Map<String, dynamic> map) {
    return _AvoidUsingEnumNameAsKeyParameter(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
    );
  }
}
