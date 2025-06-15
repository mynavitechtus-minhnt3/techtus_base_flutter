import '../index.dart';

abstract class CommonQuickFix<T extends CommonLintParameter> extends DartFix {
  CommonQuickFix(this.config) : super();

  final RuleConfig<T> config;

  T get parameters => config.parameters;
}
