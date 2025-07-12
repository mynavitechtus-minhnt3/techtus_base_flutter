import 'dart:io';
import 'dart:convert';

final camelCaseReg = RegExp(r'^[a-z][a-zA-Z0-9]*$');

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart run tool/check_l10n_keys.dart <arb_dir_or_file>');
    exit(1);
  }
  final input = args.first;
  final files = <File>[];

  final inputFile = File(input);
  if (await inputFile.exists()) {
    files.add(inputFile);
  } else {
    final dir = Directory(input);
    if (!await dir.exists()) {
      print('Not found: $input');
      exit(1);
    }
    await for (var entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.arb')) {
        files.add(entity);
      }
    }
  }

  bool hasError = false;
  for (final file in files) {
    final text = await file.readAsString();
    final data = json.decode(text) as Map<String, dynamic>;
    final l10nKeys = data.keys.where((k) => !k.startsWith('@')).toList();
    for (final key in l10nKeys) {
      if (!camelCaseReg.hasMatch(key)) {
        print('❌ [${file.path}] L10n key "$key" is not camelCase.');
        hasError = true;
      }
    }
  }
  if (hasError) {
    exit(1);
  } else {
    print('✅ All l10n keys are camelCase!');
  }
}
