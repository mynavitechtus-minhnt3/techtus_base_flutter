import 'dart:io';
import 'package:yaml/yaml.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('Usage: dart bump_pubspec.dart <build number>');
    exit(1);
  }
  final buildNumber = args[0];
  final file = File('pubspec.yaml');
  if (!file.existsSync()) {
    stderr.writeln('Error: pubspec.yaml not found in current directory.');
    exit(1);
  }

  final content = file.readAsStringSync();
  final doc = loadYamlNode(content);
  if (doc is YamlMap && doc.nodes.containsKey('version')) {
    // Extract version name before '+'
    final currentVersion = doc.nodes['version']!.value as String;
    final versionName = currentVersion.split('+').first;
    final newVersion = '$versionName+$buildNumber';

    // Replace the version line manually without using yaml_edit
    final versionRegExp = RegExp(r'^version:.*$', multiLine: true);
    final newContent = content.replaceFirst(
      versionRegExp,
      'version: $newVersion',
    );
    file.writeAsStringSync(newContent);
  } else {
    stderr.writeln('Error: `version` field not found in pubspec.yaml');
    exit(1);
  }
}
