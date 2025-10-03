import 'dart:io';

/// Check assets structure according to project conventions
/// Usage: dart run tools/dart_tools/lib/check_assets_structure.dart

void main(List<String> args) async {
  final projectRoot = Directory.current.path;
  final assetsDir = Directory('$projectRoot/assets');

  if (!await assetsDir.exists()) {
    print('❌ Assets directory not found at ${assetsDir.path}');
    exit(1);
  }

  print('🔍 Checking assets structure...');

  final errors = <String>[];

  // Check allowed directories
  await _checkAllowedDirectories(assetsDir, errors);

  // Check images structure
  await _checkImagesStructure(assetsDir, errors);

  // Check fonts structure
  await _checkFontsStructure(assetsDir, errors);

  // Check raw files structure
  await _checkRawFilesStructure(assetsDir, errors);

  if (errors.isNotEmpty) {
    print('\n❌ Assets structure validation failed:');
    for (final error in errors) {
      print('  • $error');
    }
    print('\n📋 Assets structure requirements:');
    print('  • Only 3 folders allowed: images/, fonts/, raw/');
    print('  • SVG files must be in images/ and start with "icon_"');
    print('  • Other image files must be in images/ and start with "image_"');
    print('  • Font files must be in fonts/');
    print('  • Other files must be in raw/');
    exit(1);
  }

  print('✅ Assets structure is valid!');
}

Future<void> _checkAllowedDirectories(Directory assetsDir, List<String> errors) async {
  final allowedDirs = {'images', 'fonts', 'raw'};

  await for (final entity in assetsDir.list()) {
    if (entity is Directory) {
      final dirName = entity.path.split(Platform.pathSeparator).last;
      if (!allowedDirs.contains(dirName)) {
        errors.add('Invalid directory: assets/$dirName (only images/, fonts/, raw/ are allowed)');
      }
    }
  }
}

Future<void> _checkImagesStructure(Directory assetsDir, List<String> errors) async {
  final imagesDir = Directory('${assetsDir.path}/images');
  if (!await imagesDir.exists()) return;

  await for (final entity in imagesDir.list()) {
    if (entity is File) {
      final fileName = entity.path.split(Platform.pathSeparator).last;
      final extension = fileName.split('.').last.toLowerCase();

      if (extension == 'svg') {
        if (!fileName.startsWith('icon_')) {
          errors.add('SVG file must start with "icon_": assets/images/$fileName');
        }
      } else {
        if (!fileName.startsWith('image_')) {
          errors.add('other image files must start with "image_": assets/images/$fileName');
        }
      }
    }
  }
}

Future<void> _checkFontsStructure(Directory assetsDir, List<String> errors) async {
  final fontsDir = Directory('${assetsDir.path}/fonts');
  if (!await fontsDir.exists()) return;

  await for (final entity in fontsDir.list()) {
    if (entity is File) {
      final fileName = entity.path.split(Platform.pathSeparator).last;
      final extension = fileName.split('.').last.toLowerCase();

      if (!['ttf', 'otf', 'woff', 'woff2'].contains(extension)) {
        errors.add('Only font files allowed in fonts/: assets/fonts/$fileName');
      }
    }
  }
}

Future<void> _checkRawFilesStructure(Directory assetsDir, List<String> errors) async {
  final rawDir = Directory('${assetsDir.path}/raw');
  if (!await rawDir.exists()) return;

  await for (final entity in rawDir.list()) {
    if (entity is Directory) {
      final dirName = entity.path.split(Platform.pathSeparator).last;
      errors.add('No subdirectories allowed in raw/: assets/raw/$dirName');
    }
  }
}
