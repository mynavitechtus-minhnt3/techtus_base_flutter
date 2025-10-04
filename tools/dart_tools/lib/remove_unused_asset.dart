import 'dart:io';

void main(List<String> args) async {
  final skipError = args.contains('--skip-error');
  final codeDir = Directory('${args[0]}/lib');
  final imageDir = Directory('${args[0]}/assets/images');
  final imageRefRegex = RegExp(r'\b(?:sImage|image)\.([a-zA-Z0-9_]+)\b');
  final excludes = <String>[
    './assets/images/image_app_icon.png',
  ];
  if (excludes.contains('*')) {
    print('⚠️ Exiting because excludes contains "*"');
    exit(0);
  }
  if (!imageDir.existsSync()) {
    print('❌ assets/images does not exist');
    if (skipError) {
      print('Skip error mode: Continuing despite assets/images not existing');
      exit(0);
    }
    exit(1);
  }

  print('🔍 Scanning assets and source code...');

  final allAssetFiles = imageDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) =>
          file.path.endsWith('.png') ||
          file.path.endsWith('.jpg') ||
          file.path.endsWith('.jpeg') ||
          file.path.endsWith('.webp') ||
          file.path.endsWith('.svg'))
      .toList();

  final assetMap = <String, File>{};

  for (var file in allAssetFiles) {
    final name = file.uri.pathSegments.last.split('.').first;
    final camelCaseKey = _toCamelCase(name);
    assetMap[camelCaseKey] = file;
  }

  final usedKeys = <String>{};
  await for (var entity in codeDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = await entity.readAsString();
      usedKeys.addAll(
          imageRefRegex.allMatches(content).map((e) => e.group(1)!).where((e) => e.isNotEmpty));
    }
  }

  final unusedAssets = assetMap.entries
      .where((entry) => !usedKeys.contains(entry.key) && !excludes.contains(entry.value.path))
      .map((e) => e.value)
      .toList();

  if (unusedAssets.isEmpty) {
    print('✅ No unused assets found 🎉');
    exit(0);
  }

  print('🗑 Deleting ${unusedAssets.length} unused assets:');
  for (var file in unusedAssets) {
    print('- ${file.path}');
    await file.delete();
  }

  print('✅ Deletion completed.');
  if (skipError) {
    print('Skip error mode: Continuing despite unused assets found');
    exit(0);
  }
  exit(1);
}

String _toCamelCase(String input) {
  final parts = input.split('_');
  return parts.first + parts.skip(1).map((e) => e[0].toUpperCase() + e.substring(1)).join();
}
