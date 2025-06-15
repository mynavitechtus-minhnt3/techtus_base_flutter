import '../index.dart';

/// Base option for lint rules containing common fields.
abstract class CommonLintOption extends Excludable {
  const CommonLintOption({
    this.excludes = const [],
    this.includes = const [],
    this.severity,
  });

  @override
  final List<String> excludes;

  @override
  final List<String> includes;

  /// Severity override for the lint.
  final ErrorSeverity? severity;
}
