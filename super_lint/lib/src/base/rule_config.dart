// ignore: depend_on_referenced_packages

import '../index.dart';

typedef RuleParameterParser<T> = T Function(Map<String, Object?> json);
typedef RuleProblemFactory<T> = String Function(T value);

class RuleConfig<T extends CommonLintParameter> {
  RuleConfig({
    required this.name,
    required CustomLintConfigs configs,
    required RuleProblemFactory<T> problemMessage,
    RuleParameterParser<T>? paramsParser,
  })  : enabled = configs.rules[name]?.enabled ?? false,
        parameters = paramsParser?.call(configs.rules[name]?.json ?? {}) as T,
        _problemMessageFactory = problemMessage;

  final String name;
  final bool enabled;
  final T parameters;
  final RuleProblemFactory<T> _problemMessageFactory;
  LintCode get lintCode => LintCode(
        name: name,
        problemMessage: _problemMessageFactory(parameters),
        errorSeverity: parameters.severity ?? ErrorSeverity.WARNING,
      );
}
