import 'dart:io';

void main(List<String> args) async {
  final codeDir = Directory('${args[0]}/lib');
  final imageDir = Directory('${args[0]}/assets/images');
  final imageRefRegex = RegExp(r'\b(?:sImage|image)\.([a-zA-Z0-9_]+)\b');
  final excludes = <String>[
    './assets/images/app_icon.png',
  ];
  if (!imageDir.existsSync()) {
    print('❌ assets/images không tồn tại');
    exit(1);
  }

  print('🔍 Đang quét asset và mã nguồn...');

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
    print('✅ Không có asset nào bị thừa 🎉');
    exit(0);
  }

  print('🗑 Đang xoá ${unusedAssets.length} asset không được sử dụng:');
  for (var file in unusedAssets) {
    print('- ${file.path}');
    await file.delete();
  }

  print('✅ Đã xoá xong.');
  exit(1);
}

String _toCamelCase(String input) {
  final parts = input.split('_');
  return parts.first + parts.skip(1).map((e) => e[0].toUpperCase() + e.substring(1)).join();
}
