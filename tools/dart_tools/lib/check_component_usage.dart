import 'dart:io';

import 'package:path/path.dart' as p;

const _componentRoot = 'lib/ui/component';
const _excluded = <String>[
  // Components kept for possible future reuse but currently unreferenced.
  'lib/ui/component/keyboard_visibility_builder.dart',
  'lib/ui/component/shimmer/circle_shimmer.dart',
  'lib/ui/component/shimmer/rounded_rectangle_shimmer.dart',
  'lib/ui/component/shimmer/shimmer_loading.dart',
  'lib/ui/component/common_scrollbar.dart',
  'lib/ui/component/common_app_bar.dart',
  'lib/ui/component/common_scaffold.dart',
  'lib/ui/component/common_divider.dart',
  'lib/ui/component/common_image.dart',
  'lib/ui/component/common_ink_well.dart',
  'lib/ui/component/common_scrollbar_with_ios_status_bar_tap_detector.dart',
];

Future<void> main(List<String> args) async {
  final skipError = args.contains('--skip-error');
  final componentFiles = _listDartFiles(_componentRoot);
  final projectFiles = _listDartFiles('lib');

  if (componentFiles.isEmpty) {
    stderr.writeln('No component files found in $_componentRoot');
    exit(1);
  }

  final fileContents = <String, String>{
    for (final file in projectFiles) file: File(file).readAsStringSync(),
  };

  final issues = <String>[];

  for (final path in componentFiles) {
    final relativePath = _normalizePath(path);
    if (_excluded.contains(relativePath)) {
      continue;
    }

    final content = fileContents[path]!;
    final componentName = _primaryWidgetName(content);

    if (componentName == null) {
      continue;
    }

    final usageFiles = <String>{};
    final usagePattern = RegExp('\\b$componentName\\b');

    fileContents.forEach((otherPath, otherContent) {
      if (otherPath == path) return;
      if (usagePattern.hasMatch(otherContent)) {
        usageFiles.add(_normalizePath(otherPath));
      }
    });

    if (usageFiles.length <= 1) {
      final usageNote = usageFiles.isEmpty ? 'no usage' : 'used in ${usageFiles.join(', ')}';
      issues.add('[${_normalizePath(path)}] $componentName has $usageNote');
    }
  }

  if (issues.isEmpty) {
    stdout.writeln('✅ All components are used in more than one file.');
  } else {
    stderr.writeln(
        '❌ The following components are unused or are only used within 1 screen, so they should be defined as private classes instead of public classes. If in the future they might be used across multiple screens, then for now please add them to the _excluded list in the check_component_usage.dart file:');
    for (final issue in issues) {
      stderr.writeln('  - $issue');
    }
    if (skipError) {
      stderr.writeln('Skip error mode: Continuing despite component usage issues');
    } else {
      exit(1);
    }
  }
}

List<String> _listDartFiles(String root) {
  final dir = Directory(root);
  if (!dir.existsSync()) {
    return [];
  }

  final files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .map((file) => file.path)
      .toList();

  files.sort();
  return files;
}

String? _primaryWidgetName(String content) {
  final classPattern = RegExp(r'class\s+(\w+)\s+extends\s+([\w<>.,\s]+)', multiLine: true);
  for (final match in classPattern.allMatches(content)) {
    final name = match.group(1);
    final baseType = match.group(2);
    if (name == null || baseType == null) continue;
    if (name.startsWith('_')) continue;
    if (!baseType.contains('Widget')) continue;
    return name;
  }
  return null;
}

String _normalizePath(String path) {
  return p.normalize(path).replaceAll('\\', '/');
}
