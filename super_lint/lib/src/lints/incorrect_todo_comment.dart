import '../index.dart';

class IncorrectTodoComment extends CommonLintRule<_IncorrectTodoCommentParameter> {
  IncorrectTodoComment(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
              name: 'incorrect_todo_comment',
              configs: configs,
              paramsParser: _IncorrectTodoCommentParameter.fromMap,
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

class _IncorrectTodoCommentParameter extends CommonLintParameter {
  const _IncorrectTodoCommentParameter({
    super.excludes,
    super.includes,
    super.severity,
  });

  static _IncorrectTodoCommentParameter fromMap(Map<String, dynamic> map) {
    return _IncorrectTodoCommentParameter(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
    );
  }
}
