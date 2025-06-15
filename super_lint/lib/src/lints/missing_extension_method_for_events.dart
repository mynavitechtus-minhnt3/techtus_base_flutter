import '../index.dart';

const _extendedType = 'AnalyticsHelper';

class MissingExtensionMethodForEvents
    extends OptionsLintRule<_MissingExtensionMethodForEventsOption> {
  MissingExtensionMethodForEvents(
    CustomLintConfigs configs,
  ) : super(
          RuleConfig(
            name: lintName,
            configs: configs,
            paramsParser: _MissingExtensionMethodForEventsOption.fromMap,
            problemMessage: (params) => 'Missing extension method for events for this class',
          ),
        );

  static const String lintName = 'missing_extension_method_for_events';

  @override
  Future<void> run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) async {
    final rootPath = await resolver.rootPath;
    final parameters = config.parameters;

    if (parameters.shouldSkipAnalysis(
      path: resolver.path,
      rootPath: rootPath,
    )) {
      return;
    }

    final code = this.code.copyWith(
          errorSeverity: parameters.severity ?? this.code.errorSeverity,
        );

    context.registry.addCompilationUnit((unit) {
      final extensions = <ExtensionDeclaration>[];

      for (final declaration in unit.declarations) {
        if (declaration is ExtensionDeclaration &&
            declaration.onClause?.extendedType.toString() == _extendedType) {
          extensions.add(declaration);
        }
      }

      for (final declaration in unit.declarations) {
        if (declaration is! ClassDeclaration) continue;

        final className = declaration.name.lexeme;
        if (!className.endsWith('Page')) continue;

        final hasBasePageParent =
            declaration.extendsClause?.superclass.type.toString().startsWith('BasePage') == true ||
                declaration.extendsClause?.superclass.type
                        .toString()
                        .startsWith('StatefulHookConsumerWidget') ==
                    true;
        if (!hasBasePageParent) continue;

        if (extensions.isEmpty) {
          reporter.atToken(
            declaration.name,
            code.copyWith(
              problemMessage: 'Class $className is missing extension method for logging events',
            ),
          );
          return;
        }

        final expectedExtensionName = 'AnalyticsHelperOn$className';
        final hasMatchingExtension = extensions.any((ext) {
          return ext.name?.lexeme == expectedExtensionName;
        });

        if (!hasMatchingExtension) {
          reporter.atToken(
            extensions.first.name!,
            code.copyWith(
              problemMessage: 'Invalid extension name. Expected: $expectedExtensionName',
            ),
          );
        }
      }
    });
  }

  @override
  List<Fix> getFixes() {
    return [
      _AddPrivateExtensionMethods(config),
    ];
  }
}

class _AddPrivateExtensionMethods extends OptionsFix<_MissingExtensionMethodForEventsOption> {
  _AddPrivateExtensionMethods(super.config);

  @override
  Future<void> run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) async {
    context.registry.addCompilationUnit((unit) {
      if (!unit.sourceRange.intersects(analysisError.sourceRange)) {
        return;
      }
      final extensions = <ExtensionDeclaration>[];

      for (final declaration in unit.declarations) {
        if (declaration is ExtensionDeclaration &&
            declaration.onClause?.extendedType.toString() == _extendedType) {
          extensions.add(declaration);
        }
      }

      for (final declaration in unit.declarations) {
        if (declaration is! ClassDeclaration) continue;

        final className = declaration.name.lexeme;
        if (!className.endsWith('Page')) continue;

        final hasBasePageParent =
            declaration.extendsClause?.superclass.type.toString().startsWith('BasePage') == true ||
                declaration.extendsClause?.superclass.type
                        .toString()
                        .startsWith('StatefulHookConsumerWidget') ==
                    true;
        if (!hasBasePageParent) continue;
        final expectedExtensionName = 'AnalyticsHelperOn$className';
        if (extensions.isEmpty) {
          final hasMatchingExtension = extensions.any((ext) {
            return ext.name?.lexeme == expectedExtensionName;
          });

          if (!hasMatchingExtension) {
            final content = '''
extension $expectedExtensionName on $_extendedType {}
''';
            final changeBuilder = reporter.createChangeBuilder(
              message: 'Add extension method `$expectedExtensionName`',
              priority: 7111,
            );
            changeBuilder.addDartFileEdit((builder) {
              builder.addInsertion(
                declaration.offset,
                (builder) {
                  builder.writeln(content);
                },
              );
            });
          }
          return;
        }

        final changeBuilder = reporter.createChangeBuilder(
          message: 'Rename extension to `$expectedExtensionName`',
          priority: 7113,
        );
        changeBuilder.addDartFileEdit((builder) {
          builder.addSimpleReplacement(
            extensions.first.name!.sourceRange,
            expectedExtensionName,
          );
        });
      }
    });
  }
}

class _MissingExtensionMethodForEventsOption extends Excludable {
  const _MissingExtensionMethodForEventsOption({
    this.excludes = const [],
    this.includes = const [],
    this.severity,
  });

  final ErrorSeverity? severity;
  @override
  final List<String> excludes;
  @override
  final List<String> includes;

  static _MissingExtensionMethodForEventsOption fromMap(Map<String, dynamic> map) {
    return _MissingExtensionMethodForEventsOption(
      excludes: safeCastToListString(map['excludes']),
      includes: safeCastToListString(map['includes']),
      severity: convertStringToErrorSeverity(map['severity']),
    );
  }
}
