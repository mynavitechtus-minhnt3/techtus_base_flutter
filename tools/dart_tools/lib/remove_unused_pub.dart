// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:yaml/yaml.dart';

/// Actions: 'remove', 'comment' (default)
/// Commands:
/// - make remove_unused_lib
/// - make comment_unused_lib
void main(List<String> args) async {
  final skipError = args.contains('--skip-error');
  final input = args.isNotEmpty ? args[1] : 'comment';
  final isComment = input == 'comment';
  print('$input unused lib...');

  final output = await check(
    projectPath: args[0],
    excludePackages: {'tools'},
    excludeDependencies: {
      'auto_route_generator',
      'bloc_test',
      'build_runner',
      'custom_lint',
      'dart_code_metrics',
      'mockito',
      'flutter_gen_runner',
      'flutter_launcher_icons',
      'flutter_lints',
      'flutter_native_splash',
      'flutter_test',
      'freezed',
      'injectable_generator',
      'intl_utils',
      'json_serializable',
      'mocktail',
      'objectbox_generator',
      'flutter_driver',
      'integration_test',
      'async',
      'isar_community_flutter_libs',
      'super_lint',
      'shared',
      'rxdart',
    },
  );
  print('Unused dependencies: ${output.$1}');
  print('Unused dev dependencies: ${output.$2}');

  final unusedPubs = output.$1 + output.$2;

  final pubspecPath = '${args[0]}/pubspec.yaml';
  File(pubspecPath).writeAsStringSync(
    '${File(pubspecPath).readAsLinesSync().map((e) => unusedPubs.any((pub) => e.contains(pub)) ? (isComment ? '# $e' : '# removed') : e).filter((element) => element != '# removed').join('\n')}\n',
  );

  // ✅ Exit based on result
  if (unusedPubs.isNotEmpty) {
    print('❌ Unused dependencies found. Exiting with code 1.');
    if (skipError) {
      print('Skip error mode: Continuing despite unused dependencies found');
      exit(0);
    }
    exit(1);
  }

  print('✅ No unused dependencies found. Exiting with code 0.');
  exit(0);
}

Future<(Iterable<String> dependencies, Iterable<String> devDependencies)> check({
  required String projectPath,
  Set<String>? additionalFolders,
  Set<String>? excludePackages,
  Set<String> excludeDependencies = const {},
}) async {
  final packageFile = _getPackageFile(projectPath);
  final pubspecContent = await _readPubspecFile(packageFile);
  final pubspecData = _parsePubspecContent(pubspecContent);

  final usedPackages = await _findUsedPackages(
    projectPath,
    additionalFolders,
  );

  final unusedDependencies = _findUnusedDependencies(
    pubspecData['dependencies'] as Map<String, dynamic>,
    usedPackages,
    excludePackages,
  );
  // final unusedDevDependencies = _findUnusedDependencies(
  //   pubspecData['dev_dependencies'] as Map<String, dynamic>,
  //   usedPackages,
  //   excludePackages,
  // );

  return (
    unusedDependencies.except(excludeDependencies),
    <String>[],
  );
}

File _getPackageFile(String projectPath) {
  final packageFile = File('$projectPath/pubspec.yaml');
  if (!packageFile.existsSync()) {
    throw PubspecNotFoundError(projectPath);
  }

  return packageFile;
}

Future<String> _readPubspecFile(File packageFile) async => await packageFile.readAsString();

Map<String, dynamic> _parsePubspecContent(String pubspecContent) {
  final pubspecData = json.decode(json.encode(loadYaml(pubspecContent)));

  return pubspecData as Map<String, dynamic>;
}

Future<Set<String>> _findUsedPackages(String projectPath, Set<String>? additionalFolders) async {
  final usedPackages = <String>{};
  final foldersToSearch = [
    Directory('$projectPath/lib'),
    if (additionalFolders != null) ...additionalFolders.map((folder) => Directory(folder)),
  ];
  final existingFolders = foldersToSearch.where((folder) => folder.existsSync()).toList();

  for (var folder in existingFolders) {
    await for (var file in folder.list(recursive: true)) {
      if (file is File && file.path.endsWith('.dart')) {
        final content = await file.readAsString();
        final imports = RegExp(r'package:(\w+)/').allMatches(content);

        for (var match in imports) {
          final packageName = match.group(1);
          if (packageName != null) {
            usedPackages.add(packageName);
          }
        }
      }
    }
  }

  return usedPackages;
}

Set<String> _findUnusedDependencies(
  Map<String, dynamic>? dependencies,
  Set<String> usedPackages,
  Set<String>? excludePackages,
) {
  final unusedDependencies = <String>{};

  dependencies?.forEach((dependency, _) {
    if (!usedPackages.contains(dependency) &&
        (excludePackages == null || !excludePackages.contains(dependency))) {
      unusedDependencies.add(dependency);
    }
  });

  return unusedDependencies;
}

class PubspecNotFoundError extends Error {
  PubspecNotFoundError(this.path);

  final String path;

  @override
  String toString() => 'pubspec.yaml was not found in $path';
}
