// ignore_for_file: avoid_print

import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:yaml/yaml.dart';

void main(List<String> args) {
  final excludes = ['analyzer'];
  final skipError = args.contains('--skip-error');
  final pubspecPath = args.firstWhere((arg) => !arg.startsWith('--'), orElse: () => 'pubspec.yaml');
  final pubspecContent = File(pubspecPath).readAsStringSync();
  final yaml = loadYaml(pubspecContent);
  final dependencies = yaml['dependencies'] as YamlMap? ?? {};
  final devDependencies = yaml['dev_dependencies'] as YamlMap? ?? {};
  final dependencyOverrides = yaml['dependency_overrides'] as YamlMap? ?? {};

  bool hasChanges = false;
  String updatedContent = pubspecContent;

  for (final entry in dependencies.entries) {
    if (entry.value is String && entry.value.startsWith('^') && !excludes.contains(entry.key)) {
      final oldVersion = entry.value as String;
      final newVersion = oldVersion.substring(1);
      updatedContent = updatedContent.replaceAll(
        '${entry.key}: $oldVersion',
        '${entry.key}: $newVersion',
      );
      hasChanges = true;
      print('Fixed dependency ${entry.key}: $oldVersion -> $newVersion');
    }
  }

  for (final entry in devDependencies.entries) {
    if (entry.value is String && entry.value.startsWith('^') && !excludes.contains(entry.key)) {
      final oldVersion = entry.value as String;
      final newVersion = oldVersion.substring(1);
      updatedContent = updatedContent.replaceAll(
        '${entry.key}: $oldVersion',
        '${entry.key}: $newVersion',
      );
      hasChanges = true;
      print('Fixed dev dependency ${entry.key}: $oldVersion -> $newVersion');
    }
  }

  for (final entry in dependencyOverrides.entries) {
    if (entry.value is String && entry.value.startsWith('^') && !excludes.contains(entry.key)) {
      final oldVersion = entry.value as String;
      final newVersion = oldVersion.substring(1);
      updatedContent = updatedContent.replaceAll(
        '${entry.key}: $oldVersion',
        '${entry.key}: $newVersion',
      );
      hasChanges = true;
      print('Fixed dependency override ${entry.key}: $oldVersion -> $newVersion');
    }
  }

  if (hasChanges) {
    File(pubspecPath).writeAsStringSync(updatedContent);
    print('Updated pubspec.yaml file');
  }

  final invalidDependencies = dependencies
      .filter((entry) => isInvalidPubExceptCaret(entry.value) && !excludes.contains(entry.key));
  final invalidDevDependencies = devDependencies
      .filter((entry) => isInvalidPubExceptCaret(entry.value) && !excludes.contains(entry.key));
  final invalidDependencyOverrides = dependencyOverrides
      .filter((entry) => isInvalidPubExceptCaret(entry.value) && !excludes.contains(entry.key));

  if (invalidDependencies.isNotEmpty) {
    print('Invalid dependencies: ${invalidDependencies.keys}');
  }

  if (invalidDevDependencies.isNotEmpty) {
    print('Invalid dev dependencies: ${invalidDevDependencies.keys}');
  }

  if (invalidDependencyOverrides.isNotEmpty) {
    print('Invalid dependency overrides: ${invalidDependencyOverrides.keys}');
  }

  final exitCode = hasChanges ||
          invalidDependencies.isNotEmpty ||
          invalidDevDependencies.isNotEmpty ||
          invalidDependencyOverrides.isNotEmpty
      ? 1
      : 0;

  if (hasChanges &&
      invalidDependencies.isEmpty &&
      invalidDevDependencies.isEmpty &&
      invalidDependencyOverrides.isEmpty) {
    print('All dependencies fixed successfully!');
  }

  if (skipError) {
    print('Skip error mode: Always exit with 0');
    exit(0);
  }

  print('Exit code: $exitCode');
  exit(exitCode);
}

bool isInvalidPub(dynamic pubVersion) {
  return pubVersion == null ||
      pubVersion is String &&
          (pubVersion.trim() == 'any' || pubVersion.isBlank || pubVersion.startsWith('^'));
}

bool isInvalidPubExceptCaret(dynamic pubVersion) {
  return pubVersion == null ||
      pubVersion is String && (pubVersion.trim() == 'any' || pubVersion.isBlank);
}
