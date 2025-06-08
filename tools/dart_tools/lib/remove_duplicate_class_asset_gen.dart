import 'dart:io';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('❗ Vui lòng truyền đường dẫn module (VD: apps/salon_app)');
    exit(1);
  }

  final filePath = '${args[0]}/lib/generated/assets.gen.dart';
  final importLine = "import 'package:shared/index.dart';";

  final file = File(filePath);
  if (!file.existsSync()) {
    print('❌ File không tồn tại: $filePath');
    exit(1);
  }

  final original = await file.readAsString();

  // 1. Xoá class AssetGenImage
  final removedAssetGenImage = _removeClass(original, 'AssetGenImage');

  // 2. Xoá class SvgGenImage
  final removedSvgGenImage = _removeClass(removedAssetGenImage, 'SvgGenImage');

  // 3. Chèn import nếu chưa có
  final patched = _insertImportAfterLast(removedSvgGenImage, importLine);

  // 4. Ghi đè lại file gốc
  await file.writeAsString(patched);
  print('✅ Đã cập nhật file: $filePath');
}

String _removeClass(String content, String className) {
  final classRegex = RegExp(
    r'class ' + className + r'\s*{.*?^}\s*',
    multiLine: true,
    dotAll: true,
  );
  return content.replaceAll(classRegex, '');
}

String _insertImportAfterLast(String content, String importLine) {
  if (content.contains(importLine)) return content;

  final importRegex = RegExp(r'''import\s+['\"].+?['\"];''', multiLine: true);
  final matches = importRegex.allMatches(content).toList();

  if (matches.isEmpty) {
    return "$importLine\n\n$content";
  }

  final lastImport = matches.last;
  final insertIndex = lastImport.end;

  return content.substring(0, insertIndex) + "\n$importLine" + content.substring(insertIndex);
}
