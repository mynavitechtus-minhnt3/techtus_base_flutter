import 'dart:io';

void main(List<String> arguments) {
  final basePath = arguments.isEmpty ? '.' : arguments.first;
  final generator = _AllPagesGenerator(basePath);
  generator.run();
}

class _AllPagesGenerator {
  _AllPagesGenerator(String basePath) : baseDir = Directory(basePath).absolute;

  final Directory baseDir;

  void run() {
    final allPagesFile = _file('lib/ui/page/input_pages.md');
    if (!allPagesFile.existsSync()) {
      stderr.writeln('Error: lib/ui/page/input_pages.md not found.');
      exit(1);
    }

    final rawContent = allPagesFile.readAsStringSync();
    final slugs = _parseSlugs(rawContent);
    if (slugs.isEmpty) {
      stderr.writeln('Error: lib/ui/page/input_pages.md is empty.');
      exit(1);
    }

    final screenNameFile = _file('lib/common/helper/analytics/screen_name.dart');
    if (!screenNameFile.existsSync()) {
      stderr.writeln('Error: lib/common/helper/analytics/screen_name.dart not found.');
      exit(1);
    }
    var screenNameContent = screenNameFile.readAsStringSync();
    final originalScreenNameContent = screenNameContent;

    final appRouterFile = _file('lib/navigation/routes/app_router.dart');
    if (!appRouterFile.existsSync()) {
      stderr.writeln('Error: lib/navigation/routes/app_router.dart not found.');
      exit(1);
    }
    var appRouterContent = appRouterFile.readAsStringSync();
    final originalAppRouterContent = appRouterContent;

    final appRouterGrFile = _file('lib/navigation/routes/app_router.gr.dart');
    if (!appRouterGrFile.existsSync()) {
      stderr.writeln('Error: lib/navigation/routes/app_router.gr.dart not found.');
      exit(1);
    }
    var appRouterGrContent = appRouterGrFile.readAsStringSync();
    final originalAppRouterGrContent = appRouterGrContent;
    final autoRouteAlias = _findAutoRouteAlias(appRouterGrContent);
    if (autoRouteAlias == null) {
      stderr.writeln('Error: Could not find auto_route import alias in app_router.gr.dart.');
      exit(1);
    }

    final generatedPages = <String>[];
    final skippedPages = <String>[];

    for (final slug in slugs) {
      final page = _PageDefinition(slug);
      final generated = _generatePageFiles(page);
      if (generated) {
        generatedPages.add(slug);
      } else {
        skippedPages.add(slug);
      }
      screenNameContent = _ensureScreenNameEntry(screenNameContent, page);
      appRouterContent = _ensureAppRouterEntry(appRouterContent, page);
      final importResult = _ensureAppRouterGrImport(appRouterGrContent, page);
      appRouterGrContent = importResult.content;
      appRouterGrContent = _ensureAppRouterGrRoute(
        appRouterGrContent,
        page,
        importResult.alias,
        autoRouteAlias,
      );
    }

    if (screenNameContent != originalScreenNameContent) {
      screenNameFile.writeAsStringSync(screenNameContent);
      stdout.writeln('Updated screen_name.dart');
    }

    if (appRouterContent != originalAppRouterContent) {
      appRouterFile.writeAsStringSync(appRouterContent);
      stdout.writeln('Updated app_router.dart');
    }

    if (appRouterGrContent != originalAppRouterGrContent) {
      appRouterGrFile.writeAsStringSync(appRouterGrContent);
      stdout.writeln('Updated app_router.gr.dart');
    }

    if (generatedPages.isNotEmpty) {
      stdout.writeln('Generated pages: ${generatedPages.join(', ')}');
    }

    if (skippedPages.isNotEmpty) {
      stdout.writeln('Skipped existing pages: ${skippedPages.join(', ')}');
    }
  }

  bool _generatePageFiles(_PageDefinition page) {
    final pageDir = _directory('lib/ui/page/${page.slug}');
    final viewModelDir = _directory('lib/ui/page/${page.slug}/view_model');
    final pageFile = File('${pageDir.path}/${page.slug}_page.dart');

    if (pageFile.existsSync() || File('${pageDir.path}/${page.slug}.dart').existsSync()) {
      return false;
    }

    pageDir.createSync(recursive: true);
    viewModelDir.createSync(recursive: true);

    pageFile.writeAsStringSync(_generatePageContent(page));
    File('${viewModelDir.path}/${page.slug}_view_model.dart')
        .writeAsStringSync(_generateViewModelContent(page));
    File('${viewModelDir.path}/${page.slug}_state.dart')
        .writeAsStringSync(_generateStateContent(page));
    File('${viewModelDir.path}/${page.slug}_state.freezed.dart')
        .writeAsStringSync(_generateFreezedContent(page));

    final specFile = File('${pageDir.path}/${page.slug}_spec.md');
    if (!specFile.existsSync()) {
      specFile.writeAsStringSync(_generateSpecContent(page));
    }

    final testDir = _directory('test/widget_test/ui/page/${page.slug}');
    testDir.createSync(recursive: true);
    final testFile = File('${testDir.path}/${page.slug}_page_test.dart');
    if (!testFile.existsSync()) {
      testFile.writeAsStringSync(_generateTestContent(page));
    }

    return true;
  }

  List<String> _parseSlugs(String rawContent) {
    final seen = <String>{};
    final result = <String>[];
    for (final line in rawContent.split(RegExp(r'\r?\n'))) {
      final slug = line.trim();
      if (slug.isEmpty) {
        continue;
      }
      if (seen.add(slug)) {
        result.add(slug);
      }
    }
    return result;
  }

  File _file(String relativePath) {
    return File('${baseDir.path}/$relativePath');
  }

  Directory _directory(String relativePath) {
    return Directory('${baseDir.path}/$relativePath');
  }

  String _ensureScreenNameEntry(String content, _PageDefinition page) {
    if (content.contains('${page.camelCase}Page(')) {
      return content;
    }

    final pattern = RegExp(r'\);\s*\n\s*const ScreenName');
    final match = pattern.firstMatch(content);
    if (match == null) {
      return content;
    }

    final entry = _buildScreenNameEntry(page);
    final replacement = '),\n$entry\n\n  const ScreenName';
    return content.replaceRange(match.start, match.end, replacement);
  }

  String _ensureAppRouterEntry(String content, _PageDefinition page) {
    if (content.contains('${page.routeName}.page')) {
      return content;
    }

    final listStart = content.indexOf('List<AutoRoute> get routes => [');
    if (listStart == -1) {
      return content;
    }

    final openBracketIndex = content.indexOf('[', listStart);
    if (openBracketIndex == -1) {
      return content;
    }

    var depth = 0;
    for (int i = openBracketIndex; i < content.length; i++) {
      final char = content[i];
      if (char == '[') {
        depth++;
      } else if (char == ']') {
        depth--;
        if (depth == 0) {
          final insertionIndex = i;
          final closingLineStart = content.lastIndexOf('\n', insertionIndex);
          final insertionPoint = closingLineStart == -1 ? insertionIndex : closingLineStart + 1;
          final indent = '        ';
          final entry = "${indent}AutoRoute(page: ${page.routeName}.page),\n";
          return content.replaceRange(
            insertionPoint,
            insertionPoint,
            entry,
          );
        }
      }
    }

    return content;
  }

  _ImportResult _ensureAppRouterGrImport(String content, _PageDefinition page) {
    final importPath = "package:nalsflutter/ui/page/${page.slug}/${page.slug}_page.dart";
    final existingMatch = RegExp("import '$importPath' as (_i\\d+);", multiLine: true, dotAll: true)
        .firstMatch(content);
    if (existingMatch != null) {
      return _ImportResult(content, existingMatch.group(1)!);
    }

    final aliasPattern = RegExp(r'as (_i\d+);');
    var maxAlias = 0;
    for (final match in aliasPattern.allMatches(content)) {
      final alias = match.group(1)!;
      final value = int.tryParse(alias.substring(2)) ?? 0;
      if (value > maxAlias) {
        maxAlias = value;
      }
    }
    final newAlias = '_i${maxAlias + 1}';
    final newImport = "import '$importPath' as $newAlias;";
    final insertIndex = content.indexOf('\n\n/// generated route');
    final index = insertIndex == -1 ? content.length : insertIndex;
    final prefix = content.substring(0, index);
    final suffix = content.substring(index);
    final buffer = StringBuffer();
    buffer.write(prefix);
    if (!prefix.endsWith('\n')) {
      buffer.write('\n');
    }
    buffer.writeln(newImport);
    buffer.write(suffix);
    return _ImportResult(buffer.toString(), newAlias);
  }

  String _ensureAppRouterGrRoute(
    String content,
    _PageDefinition page,
    String alias,
    String autoRouteAlias,
  ) {
    if (content.contains('class ${page.routeName} ')) {
      return content;
    }

    final routeClass = '''/// generated route for
/// [$alias.${page.pascalName}Page]
class ${page.routeName} extends $autoRouteAlias.PageRouteInfo<void> {
  const ${page.routeName}({List<$autoRouteAlias.PageRouteInfo>? children})
      : super(${page.routeName}.name, initialChildren: children);

  static const String name = '${page.routeName}';

  static $autoRouteAlias.PageInfo page = $autoRouteAlias.PageInfo(
    name,
    builder: (data) {
      return const $alias.${page.pascalName}Page();
    },
  );
}
''';

    final trimmed = content.trimRight();
    final buffer = StringBuffer(trimmed);
    if (trimmed.isNotEmpty) {
      buffer.writeln();
      buffer.writeln();
    }
    buffer.write(routeClass.trimRight());
    buffer.writeln();
    return buffer.toString();
  }

  String _generatePageContent(_PageDefinition page) {
    return '''import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../index.dart';

@RoutePage()
class ${page.pascalName}Page extends BasePage<${page.pascalName}State,
    AutoDisposeStateNotifierProvider<${page.pascalName}ViewModel, CommonState<${page.pascalName}State>>> {
  const ${page.pascalName}Page({super.key});

  @override
  ScreenViewEvent get screenViewEvent =>
      ScreenViewEvent(screenName: ScreenName.${page.camelCase}Page);

  @override
  AutoDisposeStateNotifierProvider<${page.pascalName}ViewModel, CommonState<${page.pascalName}State>> get provider =>
      ${page.camelCase}ViewModelProvider;

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    return CommonScaffold(
      body: Container(),
    );
  }
}
''';
  }

  String _generateViewModelContent(_PageDefinition page) {
    return '''import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../index.dart';

final ${page.camelCase}ViewModelProvider =
    StateNotifierProvider.autoDispose<${page.pascalName}ViewModel, CommonState<${page.pascalName}State>>(
  (ref) => ${page.pascalName}ViewModel(),
);

class ${page.pascalName}ViewModel extends BaseViewModel<${page.pascalName}State> {
  ${page.pascalName}ViewModel() : super(const CommonState(data: ${page.pascalName}State()));
}
''';
  }

  String _generateStateContent(_PageDefinition page) {
    return '''import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../index.dart';

part '${page.slug}_state.freezed.dart';

@freezed
sealed class ${page.pascalName}State extends BaseState with _\$${page.pascalName}State {
  const ${page.pascalName}State._();

  const factory ${page.pascalName}State() = _${page.pascalName}State;
}
''';
  }

  String _generateFreezedContent(_PageDefinition page) {
    final className = page.pascalName;
    final buffer = StringBuffer();
    buffer.writeln('// dart format width=80');
    buffer.writeln('// coverage:ignore-file');
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// ignore_for_file: type=lint');
    buffer.writeln(
        '// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark');
    buffer.writeln();
    buffer.writeln("part of '${page.slug}_state.dart';");
    buffer.writeln();
    buffer.writeln('// **************************************************************************');
    buffer.writeln('// FreezedGenerator');
    buffer.writeln('// **************************************************************************');
    buffer.writeln();
    buffer.writeln('// dart format off');
    buffer.writeln('T _\$identity<T>(T value) => value;');
    buffer.writeln();
    buffer.writeln('/// @nodoc');
    buffer.writeln('mixin _\$${className}State {');
    buffer.writeln('  @override');
    buffer.writeln('  bool operator ==(Object other) {');
    buffer.writeln('    return identical(this, other) ||');
    buffer.writeln('        (other.runtimeType == runtimeType && other is ${className}State);');
    buffer.writeln('  }');
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln('  int get hashCode => runtimeType.hashCode;');
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln("  String toString() {\n    return '${className}State()';\n  }");
    buffer.writeln('}');
    buffer.writeln();
    buffer.writeln('/// @nodoc');
    buffer.writeln('class \$${className}StateCopyWith<\$Res> {');
    buffer.writeln(
        '  \$${className}StateCopyWith(${className}State _, \$Res Function(${className}State) __);');
    buffer.writeln('}');
    buffer.writeln();
    buffer.writeln('/// @nodoc');
    buffer.writeln();
    buffer.writeln('class _${className}State extends ${className}State {');
    buffer.writeln('  const _${className}State() : super._();');
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln('  bool operator ==(Object other) {');
    buffer.writeln('    return identical(this, other) ||');
    buffer.writeln('        (other.runtimeType == runtimeType && other is _${className}State);');
    buffer.writeln('  }');
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln('  int get hashCode => runtimeType.hashCode;');
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln("  String toString() {\n    return '${className}State()';\n  }");
    buffer.writeln('}');
    buffer.writeln();
    buffer.writeln('// dart format on');
    return buffer.toString();
  }

  String _generateSpecContent(_PageDefinition page) {
    return '''''';
  }

  String _generateTestContent(_PageDefinition page) {
    final pascal = page.pascalName;
    final camel = page.camelCase;
    final slug = page.slug;
    return '''import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nalsflutter/index.dart';

import '../../../../common/index.dart';

class Mock${pascal}ViewModel extends StateNotifier<CommonState<${pascal}State>>
    with Mock
    implements ${pascal}ViewModel {
  Mock${pascal}ViewModel(super.state);
}

${pascal}ViewModel _build${pascal}ViewModel([
  CommonState<${pascal}State>? state,
]) {
  return Mock${pascal}ViewModel(state ?? const CommonState(data: ${pascal}State()));
}

void main() {
  group('design', () {
    testGoldens(
      'placeholder',
      (tester) async {
        await tester.testWidget(
          filename: '${slug}_page/placeholder',
          widget: const ${pascal}Page(),
          overrides: [
            ${camel}ViewModelProvider.overrideWith(
              (_) => _build${pascal}ViewModel(),
            ),
          ],
        );
      },
      skip: true,
    );
  });

  group('others', () {
    testGoldens(
      'default state',
      (tester) async {
        await tester.testWidget(
          filename: '${slug}_page/default state',
          widget: const ${pascal}Page(),
          overrides: [
            ${camel}ViewModelProvider.overrideWith(
              (_) => _build${pascal}ViewModel(),
            ),
          ],
        );
      },
      skip: true,
    );
  });
}
''';
  }

  String _buildScreenNameEntry(_PageDefinition page) {
    final buffer = StringBuffer();
    buffer.writeln('  ${page.camelCase}Page(');
    buffer.writeln("    screenName: '${page.title} Page',");
    buffer.writeln("    screenEventPrefix: '${page.slug}',");
    buffer.writeln("    screenClass: '${page.pascalName}Page',");
    buffer.write('  );');
    return buffer.toString();
  }
}

class _ImportResult {
  _ImportResult(this.content, this.alias);

  final String content;
  final String alias;
}

String? _findAutoRouteAlias(String content) {
  final match = RegExp(
    "import 'package:auto_route/auto_route.dart' as (_i\\d+);",
  ).firstMatch(content);
  return match?.group(1);
}

class _PageDefinition {
  _PageDefinition(this.slug)
      : pascalName = _toPascalCase(slug),
        camelCase = _toCamelCase(slug),
        title = _toTitleCase(slug),
        routeName = '${_toPascalCase(slug)}Route';

  final String slug;
  final String pascalName;
  final String camelCase;
  final String title;
  final String routeName;

  static String _toPascalCase(String value) {
    final parts = _splitParts(value);
    return parts.map((part) => part[0].toUpperCase() + part.substring(1)).join();
  }

  static String _toCamelCase(String value) {
    final parts = _splitParts(value);
    if (parts.isEmpty) {
      return value;
    }
    final first = parts.first.toLowerCase();
    final rest = parts.skip(1).map((part) => part[0].toUpperCase() + part.substring(1)).join();
    return '$first$rest';
  }

  static String _toTitleCase(String value) {
    final parts = _splitParts(value);
    return parts.map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase()).join(' ');
  }

  static List<String> _splitParts(String value) {
    return value
        .split(RegExp(r'[_\s-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part.toLowerCase())
        .toList();
  }
}
