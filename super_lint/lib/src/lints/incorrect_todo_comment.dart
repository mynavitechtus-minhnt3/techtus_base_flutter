import '../index.dart';

class IncorrectTodoComment extends CommonLintRule<_IncorrectTodoCommentOption> {
  IncorrectTodoComment(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
              name: 'incorrect_todo_comment',
              configs: configs,
              paramsParser: _IncorrectTodoCommentOption.fromMap,
              problemMessage: (_) =>
                  'TODO comments must have username, description and issue number (or #0 if no issue).\n'
                  'Example: // TODO(username): some description text #123.'),
        );

  @override
  Future<void> check(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
    String rootPath,
  ) async {
    resolver.getLineContents((codeLine) {
      if (codeLine.isEndOfLineComment) {
        if (codeLine.content.contains(RegExp(r'//\s*TODO')) &&
            !RegExp(r'^\/\/\s*TODO\(.+\):.*\S.*#\d+.*$').hasMatch(codeLine.content.trim())) {
          reporter.atOffset(
            offset: codeLine.lineOffset,
            length: codeLine.lineLength,
            errorCode: code,
          );
        }
      }
    });
  }
}

class _IncorrectTodoCommentOption extends CommonLintParameter {
  const _IncorrectTodoCommentOption({
    super.excludes,
    super.includes,
    super.severity,
  });

  static _IncorrectTodoCommentOption fromMap(Map<String, dynamic> map) {
    return _IncorrectTodoCommentOption(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
    );
  }
}
