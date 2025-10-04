import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  final skipError = args.contains('--skip-error');
  final dartDir = args[0].substring(0, args[0].lastIndexOf('lib/') + 4);
  final arbDir = args[0];

  // Get all .arb files
  final arbFiles = Directory(arbDir)
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.arb'))
      .toList();

  // Get all keys from .arb files
  final arbKeys = <String>{};
  final arbContents = <String, Map<String, dynamic>>{};
  for (final file in arbFiles) {
    final content = await File(file.path).readAsString();
    final Map<String, dynamic> data = json.decode(content);
    arbContents[file.path] = data;
    arbKeys.addAll(data.keys.where((key) => !key.startsWith('@'))); // Ignore metadata keys
  }

  // Get all Dart files in the lib folder
  final dartFiles = Directory(dartDir)
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();

  // Find all used keys in Dart files
  final usedKeys = <String>{};
  final regex = RegExp(r'\bs?l10n\.([a-zA-Z0-9_]+)\b'); // Matches `l10n.keyName`

  for (final file in dartFiles) {
    final content = await File(file.path).readAsString();
    final matches = regex.allMatches(content);
    for (final match in matches) {
      usedKeys.add(match.group(1)!);
    }
  }

  // Find unused keys
  final unusedKeys = arbKeys.difference(usedKeys);

  if (unusedKeys.isEmpty) {
    print('No unused keys found. 🎉');
    exit(0);
  } else {
    print('Removing unused keys:');
    for (final key in unusedKeys) {
      print('- $key');
    }

    // Remove unused keys from each .arb file
    for (final entry in arbContents.entries) {
      final filePath = entry.key;
      final content = entry.value;

      // Remove unused keys
      final updatedContent = Map.from(content)..removeWhere((key, _) => unusedKeys.contains(key));

      // Pretty-print and write back to the file
      final prettyContent = JsonEncoder.withIndent('  ').convert(updatedContent);
      await File(filePath).writeAsString(prettyContent);

      print('Updated file: $filePath');
    }

    print('Unused keys have been removed.');
    if (skipError) {
      print('Skip error mode: Continuing despite unused keys found');
      exit(0);
    }
    exit(1);
  }
}
