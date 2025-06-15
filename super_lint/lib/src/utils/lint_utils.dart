import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

import '../index.dart';

bool shouldSkipFile({
  required List<String> includeGlobs,
  required List<String> excludeGlobs,
  required String path,
  String? rootPath,
}) {
  final relative = relativePath(path, rootPath);
  final shouldAnalyzeFile = (includeGlobs.isEmpty || _matchesAnyGlob(includeGlobs, relative)) &&
      (excludeGlobs.isEmpty || _doesNotMatchGlobs(excludeGlobs, relative));
  return !shouldAnalyzeFile;
}

bool _matchesAnyGlob(List<String> globsList, String path) {
  final hasMatch = globsList.map(Glob.new).toList().any((glob) => glob.matches(path));
  return hasMatch;
}

bool _doesNotMatchGlobs(List<String> globList, String path) {
  return !_matchesAnyGlob(globList, path);
}

String relativePath(String path, [String? root]) {
  final uriNormlizedPath = p.toUri(path).normalizePath().path;
  final uriNormlizedRoot = root != null ? p.toUri(root).normalizePath().path : null;

  final relative = p.posix.relative(uriNormlizedPath, from: uriNormlizedRoot);
  return relative;
}

String getFileNameFromPath(String path) {
  final uri = p.toUri(path);
  final uriNormlizedPath = uri.normalizePath().path;
  final fileName = p.basenameWithoutExtension(uriNormlizedPath);
  return fileName;
}

String convertSnakeCaseToPascalCase(String snakeCase) {
  final words = snakeCase.split('_');
  final pascalCase = words.map((word) => word[0].toUpperCase() + word.substring(1)).join('');
  return pascalCase;
}

extension StringExtension on String {
  String replaceLast({
    required Pattern pattern,
    required String replacement,
  }) {
    final match = pattern.allMatches(this).lastOrNull;
    if (match == null) {
      return this;
    }
    final prefix = substring(0, match.start);
    final suffix = substring(match.end);

    return '$prefix$replacement$suffix';
  }

  bool get isSnakeCase {
    final snakeCaseRegex = RegExp(r'^[a-z0-9]+(_[a-z0-9]+)*$');
    return snakeCaseRegex.hasMatch(this);
  }

  String snakeToPascal() {
    return this
        .split('_')
        .map((s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : '')
        .join();
  }
}

T run<T>(T Function() block) {
  return block();
}

extension ObjectUtils<T> on T? {
  R? safeCast<R>() {
    final that = this;
    if (that is R) {
      return that;
    }

    return null;
  }

  R? let<R>(R Function(T)? cb) {
    final that = this;
    if (that == null) {
      return null;
    }

    return cb?.call(that);
  }
}

T? safeCast<T>(dynamic value) {
  if (value is T) {
    return value;
  }

  return null;
}

List<String> safeCastToListString(
  dynamic value, {
  List<String> defaultValue = const [],
}) {
  if (value is List<String>) {
    return value;
  }

  if (value is YamlList) {
    return value.map((element) => element.toString()).toList();
  }

  return defaultValue;
}

List<Map<String, String>> safeCastToListJson(
  dynamic value, {
  List<Map<String, String>> defaultValue = const [],
}) {
  if (value is List<Map<String, String>>) {
    return value;
  }

  if (value is YamlList) {
    return value.map((element) => safeCastToJson(element)).toList();
  }

  return defaultValue;
}

Map<String, String> safeCastToJson(
  dynamic value, {
  Map<String, String> defaultValue = const {},
}) {
  if (value is Map<String, String>) {
    return value;
  }

  if (value is YamlMap) {
    return value.cast<String, String>();
  }

  return defaultValue;
}

ErrorSeverity convertStringToErrorSeverity(Object? value) {
  return switch (value) {
    'info' => ErrorSeverity.INFO,
    'warning' => ErrorSeverity.WARNING,
    'error' => ErrorSeverity.ERROR,
    'none' => ErrorSeverity.NONE,
    _ => ErrorSeverity.WARNING,
  };
}

extension AstNodeExt on AstNode {
  ClassDeclaration? get parentClassDeclaration => thisOrAncestorOfType<ClassDeclaration>();

  List<MethodInvocation> get childMethodInvocations {
    final methodInvocations = <MethodInvocation>[];
    visitChildren(MethodInvocationVisitor(
      onVisitMethodInvocation: methodInvocations.add,
    ));

    return methodInvocations;
  }

  List<AwaitExpression> get childAwaitExpressions {
    final awaitExpressions = <AwaitExpression>[];
    visitChildren(AwaitExpressionVisitor(
      onVisitAwaitExpression: awaitExpressions.add,
    ));

    return awaitExpressions;
  }

  List<ReturnStatement> get childReturnStatements {
    final returnStatements = <ReturnStatement>[];
    visitChildren(ReturnStatementVisitor(
      onVisitReturnStatement: returnStatements.add,
    ));

    return returnStatements;
  }

  List<Statement> get childStatements {
    final statements = <Statement>[];
    visitChildren(StatementVisitor(
      onVisitExpressionStatement: statements.add,
      onVisitReturnStatement: statements.add,
    ));

    return statements;
  }

  SourceRange get sourceRange => SourceRange(offset, length);
}

extension FunctionDeclarationExt on FunctionDeclaration {
  bool get isPrivate => Identifier.isPrivateName(name.lexeme);

  bool get isAnnotation => metadata.any(
        (node) => node.atSign.type == TokenType.AT,
      );
}

extension DartFileEditBuilderExt on DartFileEditBuilder {
  void formatWithPageWidth(SourceRange range, {int pageWidth = 100}) {
    if (this is! DartFileEditBuilderImpl) {
      format(range);

      return;
    }

    final builder = this as DartFileEditBuilderImpl;

    var newContent = builder.resolvedUnit.content;
    var newRangeOffset = range.offset;
    var newRangeLength = range.length;
    for (var edit in builder.fileEdit.edits) {
      newContent = edit.apply(newContent);

      final lengthDelta = edit.replacement.length - edit.length;
      if (edit.offset < newRangeOffset) {
        newRangeOffset += lengthDelta;
      } else if (edit.offset < newRangeOffset + newRangeLength) {
        newRangeLength += lengthDelta;
      }
    }

    final formattedResult =
        DartFormatter(languageVersion: DartFormatter.latestLanguageVersion, pageWidth: pageWidth)
            .formatSource(
      SourceCode(
        newContent,
        isCompilationUnit: true,
        selectionStart: newRangeOffset,
        selectionLength: newRangeLength,
      ),
    );

    builder.replaceEdits(
      range,
      SourceEdit(
        range.offset,
        range.length,
        formattedResult.selectedText,
      ),
    );
  }
}

extension CustomLintResolverExt on CustomLintResolver {
  Future<String> get rootPath async =>
      (await getResolvedUnitResult()).session.analysisContext.contextRoot.root.path;

  void getLineContents(void Function(CodeLine codeLine) onCodeLine) {
    var previousLineContent = '';
    var isMultiLineComment = false;
    for (final startOffset in lineInfo.lineStarts) {
      final lineCount = lineInfo.lineStarts.length;
      final lineNumber = lineInfo.getLocation(startOffset).lineNumber;
      if (lineNumber <= lineCount - 1) {
        final startOffsetOfNextLine = lineInfo.getOffsetOfLineAfter(startOffset);
        final lineLength = startOffsetOfNextLine - startOffset - 1;
        final content = source.contents.data.substring(
          startOffset,
          startOffsetOfNextLine,
        );

        final isDocumentationComment = content.trim().startsWith('///');

        final isSingleLineComment = content.trim().startsWith('//') && !isDocumentationComment;

        if (content.trim().startsWith('/*')) {
          isMultiLineComment = true;
        }

        if (previousLineContent.trim().endsWith('*/') && isMultiLineComment) {
          isMultiLineComment = false;
        }

        previousLineContent = content;

        onCodeLine(
          CodeLine(
            lineNumber: lineNumber,
            lineOffset: startOffset,
            lineLength: lineLength,
            content: content,
            isEndOfLineComment: isSingleLineComment,
            isBlockComment: isMultiLineComment,
            isDocumentationComment: isDocumentationComment,
          ),
        );
      }
    }
  }

  SourceRange get documentRange => SourceRange(
        0,
        documentLength,
      );

  int get documentLength {
    try {
      return lineInfo.getOffsetOfLineAfter(lineInfo.lineStarts[lineInfo.lineStarts.length - 2]) - 1;
    } catch (_) {
      return 0;
    }
  }
}

extension DartTypeExt on DartType {
  bool get isNullableType => nullabilitySuffix == NullabilitySuffix.question;

  bool get isVoidType => this is VoidType;

  bool get isDynamicType => this is DynamicType;

  bool get isEnum => element3?.toString().startsWith('enum') ?? false;
}

extension MethodDeclarationExt on MethodDeclaration {
  List<MethodDeclaration> get pearMethodDeclarations {
    return parentClassDeclaration?.childEntities.whereType<MethodDeclaration>().toList() ??
        <MethodDeclaration>[];
  }

  bool get isOverrideMethod => metadata.any(
        (node) => node.name.name == 'override' && node.atSign.type == TokenType.AT,
      );
}

extension MethodInvocationExt on MethodInvocation {
  String? get classNameOfStaticMethod {
    if (target is SimpleIdentifier) {
      return (target as SimpleIdentifier).name;
    }

    return null;
  }
}

extension LintCodeCopyWith on LintCode {
  LintCode copyWith({
    String? name,
    String? problemMessage,
    String? correctionMessage,
    String? uniqueName,
    String? url,
    ErrorSeverity? errorSeverity,
  }) =>
      LintCode(
        name: name ?? this.name,
        problemMessage: problemMessage ?? this.problemMessage,
        correctionMessage: correctionMessage ?? this.correctionMessage,
        uniqueName: uniqueName ?? this.uniqueName,
        url: url ?? this.url,
        errorSeverity: errorSeverity ?? this.errorSeverity,
      );
}
