// ignore_for_file: avoid_print

import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart gen_assets.dart <app_path> [--package=<package_name>]');
    print('Example: dart gen_assets.dart .');
    print('Example: dart gen_assets.dart apps/shared --package=shared');
    exit(1);
  }

  final appPath = args[0];
  String? packageName;

  // Parse package argument
  for (int i = 1; i < args.length; i++) {
    if (args[i].startsWith('--package=')) {
      packageName = args[i].split('=')[1];
    }
  }

  final imagesPath = '$appPath/assets/images';
  var outputAssetsPath = '$appPath/lib/resource/app_images.dart';

  final imagesDir = Directory(imagesPath);
  if (!imagesDir.existsSync()) {
    print('Error: Images directory not found at $imagesPath');
    exit(1);
  }

  final imageFiles = imagesDir
      .listSync()
      .where((file) => file is File)
      .map((file) => file.path)
      .where((path) => _isImageFile(path))
      .map((path) => path.split('/').last)
      .toList()
    ..sort();

  if (imageFiles.isEmpty) {
    print('Warning: No image files found in $imagesPath');
  } else {
    final content = _generateAssetsContent(imageFiles, appPath, packageName);
    final outputDir = Directory(outputAssetsPath).parent;
    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }
    final outputFile = File(outputAssetsPath);
    outputFile.writeAsStringSync(content);

    print('Found ${imageFiles.length} image files');
    print('Output: $outputAssetsPath');
  }

  // --- Generate app_fonts.dart từ assets/fonts ---
  final fontsPath = '$appPath/assets/fonts';
  final outputFontsPath = '$appPath/lib/resource/app_fonts.dart';
  final fontsDir = Directory(fontsPath);

  if (!fontsDir.existsSync()) {
    print('Warning: Fonts directory not found at $fontsPath');
    return;
  }

  // Lấy tất cả file font (ttf, otf, woff, woff2) trong thư mục fonts và subfolder
  final fontFiles = fontsDir
      .listSync(recursive: true)
      .where((file) => file is File)
      .map((file) => file.path)
      .where((path) => _isFontFile(path))
      .toList()
    ..sort();

  if (fontFiles.isEmpty) {
    print('Warning: No font files found in $fontsPath');
    return;
  }

  final fontFamilies = _extractFontFamilies(fontFiles);
  final fontContent = _generateFontsContent(fontFamilies);

  final outputFontsDir = Directory(outputFontsPath).parent;
  if (!outputFontsDir.existsSync()) {
    outputFontsDir.createSync(recursive: true);
  }
  final outputFontFile = File(outputFontsPath);
  outputFontFile.writeAsStringSync(fontContent);

  print('Found ${fontFamilies.length} font families');
  print('Output: $outputFontsPath');
}

// --- Font utils ---
bool _isFontFile(String path) {
  final extension = path.split('.').last.toLowerCase();
  return ['ttf', 'otf', 'woff', 'woff2'].contains(extension);
}

// Lấy danh sách font family từ tên file font (cả subfolder)
Set<String> _extractFontFamilies(List<String> fontFiles) {
  final Set<String> families = {};
  for (final file in fontFiles) {
    final parts = file.replaceAll('\\', '/').split('/');

    // Tìm thư mục fonts trong path
    final fontsIndex = parts.indexOf('fonts');
    if (fontsIndex == -1) continue;

    // Lấy tên font family từ thư mục ngay sau fonts
    if (fontsIndex + 1 < parts.length) {
      final fontFamily = parts[fontsIndex + 1];
      if (fontFamily.isNotEmpty && fontFamily != 'static') {
        families.add(fontFamily);
        continue;
      }
    }

    // Fallback: lấy tên file (không extension)
    final name = parts.last.split('.').first;
    families.add(name);
  }
  return families;
}

// Sinh nội dung file app_fonts.dart
String _generateFontsContent(Set<String> fontFamilies) {
  final buffer = StringBuffer();
  buffer.writeln('class FontFamily {');
  buffer.writeln('  FontFamily._();\n');
  for (final family in fontFamilies) {
    buffer.writeln('  /// Font family: $family');
    buffer.writeln("  static const String ${_toCamelCase(family)} = '$family';\n");
  }
  buffer.writeln('}');
  return buffer.toString();
}

// Chuyển tên font sang camelCase cho tên biến
String _toCamelCase(String input) {
  if (input.isEmpty) return input;
  final parts = input.split(RegExp(r'[_\s-]'));
  final first = parts.first.toLowerCase();
  final rest =
      parts.skip(1).map((e) => e.isEmpty ? '' : e[0].toUpperCase() + e.substring(1)).join();
  return first + rest;
}

// --- Image utils ---
bool _isImageFile(String path) {
  final extension = path.split('.').last.toLowerCase();
  return ['png', 'jpg', 'jpeg', 'svg', 'gif', 'webp'].contains(extension);
}

String _generateAssetsContent(List<String> imageFiles, String appPath, String? packageName) {
  final getterMethods =
      imageFiles.map((file) => _generateGetterMethod(file, packageName)).join('\n\n');
  final valuesList = imageFiles.map((file) => _getGetterName(file)).join(',\n        ');

  // Generate for package format (assetsgen.dart)
  return '''class \$AssetsImagesGen {
  const \$AssetsImagesGen();

$getterMethods

  /// List of all assets
  List<String> get values => [
         $valuesList
      ];
}

class Assets {
  const Assets._();

  static const \$AssetsImagesGen images = \$AssetsImagesGen();
}
''';
}

String _generateGetterMethod(String fileName, String? packageName) {
  final name = _getGetterName(fileName);
  final path = packageName != null
      ? 'packages/$packageName/assets/images/$fileName'
      : 'assets/images/$fileName';

  return '''String get $name => '$path';''';
}

String _getGetterName(String fileName) {
  // Remove extension
  final nameWithoutExt = fileName.split('.').first;

  // First split by underscore, then by spaces, then flatten
  final underscoreParts = nameWithoutExt.split('_');
  final allParts = <String>[];

  for (final part in underscoreParts) {
    if (part.contains(' ')) {
      allParts.addAll(part.split(' '));
    } else {
      allParts.add(part);
    }
  }

  // Remove empty parts and filter out non-alphanumeric characters
  final cleanParts = allParts
      .where((part) => part.isNotEmpty)
      .map((part) => part.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ''))
      .where((part) => part.isNotEmpty)
      .toList();

  if (cleanParts.isEmpty) return 'asset';

  final firstPart = cleanParts.first.toLowerCase();
  final remainingParts = cleanParts.skip(1).map((part) {
    if (part.isEmpty) return part;
    return part[0].toUpperCase() + part.substring(1).toLowerCase();
  }).join('');

  return firstPart + remainingParts;
}
