import 'dart:io';

/// Reset project by removing example code and cleaning up files
/// Usage: dart run tools/dart_tools/lib/reset_project.dart

// Constants
final filesToDelete = [
  // UI Components
  'lib/ui/component/avatar_view.dart',
  'lib/ui/component/primary_text_field.dart',
  'lib/ui/component/search_text_field.dart',

  // Widget Tests
  'test/widget_test/ui/component/avatar_view_test.dart',
  'test/widget_test/ui/component/primary_text_field_test.dart',
  'test/widget_test/ui/component/search_text_field_test.dart',

  // Unit Tests
  'test/unit_test/ui/page/main/view_model/main_view_model_test.dart',
];

// Directories to delete (including all contents)
final directoriesToDelete = [
  'test/widget_test/ui/component/goldens/avatar_view',
  'test/widget_test/ui/component/goldens/primary_text_field',
  'test/widget_test/ui/component/goldens/search_text_field',
  'integration_test',
];

final subDirsToDelete = [
  'lib/ui/page',
  'test/unit_test/ui/page',
  'test/widget_test/ui/page',
];

final excludeDirsFromDeletion = [
  'splash',
  'main',
];

final excludeRoutesFromDeletion = [
  'splash',
  'login',
  'main',
  'home',
  'my_profile',
];

Future<void> main(List<String> args) async {
  final projectRoot = Directory.current.path;

  print('🔄 Starting project reset...');

  // Apply cleanup with error handling
  await _updateWithErrorHandling('Example Code Cleanup', () => _cleanupExampleCode(projectRoot));
  await _updateWithErrorHandling(
      'Shared Provider Cleanup', () => _cleanupSharedProvider(projectRoot));
  await _updateWithErrorHandling(
      'Shared Provider Test Cleanup', () => _cleanupSharedProviderTest(projectRoot));
  await _updateWithErrorHandling(
      'Shared ViewModel Cleanup', () => _cleanupSharedViewModel(projectRoot));
  await _updateWithErrorHandling(
      'Shared ViewModel Test Cleanup', () => _cleanupSharedViewModelTest(projectRoot));
  await _updateWithErrorHandling('App Colors Cleanup', () => _cleanupAppColors(projectRoot));
  await _updateWithErrorHandling('App Router Cleanup', () => _cleanupAppRouter(projectRoot));
  await _updateWithErrorHandling(
      'Main ViewModel Cleanup', () => _cleanupMainViewModel(projectRoot));
  await _updateWithErrorHandling(
      'Base Test Blocks Cleanup', () => _cleanupBaseTestBlocks(projectRoot));

  if (exitCode == 0) {
    print('✅ Project reset completed successfully.');
  } else {
    print('❌ Some cleanup operations failed. Please check the errors above.');
  }
}

// Error handling wrapper
Future<void> _updateWithErrorHandling(String component, Future<void> Function() updateFn) async {
  try {
    await updateFn();
    print('✅ Updated $component');
  } catch (e) {
    stderr.writeln('❌ Failed to update $component: $e');
    stderr.writeln('💡 Please check your configuration and try again');
    exitCode = 1;
  }
}

Future<void> _cleanupExampleCode(String root) async {
  // List of example files and directories to delete

  // Delete files
  for (final filePath in filesToDelete) {
    final file = File(pathOf(root, filePath));
    if (await file.exists()) {
      await file.delete();
      print('🗑️  Deleted: $filePath');
    }
  }

  // Delete subdirectories (excluding those in excludeDirsFromDeletion)
  for (final dirPath in subDirsToDelete) {
    // list all subdirectories under dir
    Directory dir = Directory(pathOf(root, dirPath));
    if (!await dir.exists()) continue;
    final subDirs = await dir
        .list(recursive: false, followLinks: false)
        .where((e) => e is Directory)
        .map((e) => e.path.split(Platform.pathSeparator).last)
        .toList();

    for (final subDirPath in subDirs) {
      final fullSubDirPath = '$dirPath/$subDirPath';
      // Check if directory path contains any excluded patterns
      final shouldExclude =
          excludeDirsFromDeletion.any((excludePattern) => fullSubDirPath.contains(excludePattern));

      if (shouldExclude) {
        print('⏭️  Skipped directory (excluded): $fullSubDirPath');
        continue;
      }
      Directory subDir = Directory(pathOf(root, fullSubDirPath));
      if (await subDir.exists()) {
        await subDir.delete(recursive: true);
        print('🗑️  Deleted directory: $fullSubDirPath');
      }
    }
  }

  // Delete directories (excluding those in excludeDirsFromDeletion)
  for (final dirPath in directoriesToDelete) {
    final directory = Directory(pathOf(root, dirPath));
    if (await directory.exists()) {
      await directory.delete(recursive: true);
      print('🗑️  Deleted directory: $dirPath');
    }
  }
}

Future<void> _cleanupSharedProvider(String root) async {
  final sharedProviderFile = File(pathOf(root, 'lib/ui/shared/shared_provider.dart'));
  if (!await sharedProviderFile.exists()) return;

  var content = await sharedProviderFile.readAsString();

  // Remove code below comment "/// Below code will be removed after running `make init`"
  final commentPattern =
      RegExp(r'/// Below code will be removed after running `make init`[\s\S]*$', multiLine: true);
  content = content.replaceAll(commentPattern, '');

  // Remove specific import
  content = content.replaceAll(RegExp(r"import 'package:dartx/dartx\.dart';\n?"), '');

  // Clean up extra blank lines
  content = content.replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n');

  await sharedProviderFile.writeAsString(content);
  print('🗑️  Cleaned up shared_provider.dart');
}

Future<void> _cleanupSharedProviderTest(String root) async {
  final testFile = File(pathOf(root, 'test/unit_test/ui/shared/shared_provider_test.dart'));
  if (!await testFile.exists()) return;

  var content = await testFile.readAsString();

  // Remove test groups below comment "/// Below code will be removed after running `make init`"
  final commentPattern =
      RegExp(r'/// Below code will be removed after running `make init`[\s\S]*$', multiLine: true);
  content = content.replaceAll(commentPattern, '');

  // Remove specific import
  content =
      content.replaceAll(RegExp(r"import 'package:hooks_riverpod/hooks_riverpod\.dart';\n?"), '');

  // Clean up extra blank lines
  content = content.replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n');

  // Ensure file ends with closing brace if it doesn't
  content = content.trim();
  content += '}\n';

  await testFile.writeAsString(content);
  print('🗑️  Cleaned up shared_provider_test.dart');
}

Future<void> _cleanupSharedViewModel(String root) async {
  final sharedViewModelFile = File(pathOf(root, 'lib/ui/shared/shared_view_model.dart'));
  if (!await sharedViewModelFile.exists()) return;

  var content = await sharedViewModelFile.readAsString();

  // Remove code below comment "/// Below code will be removed after running `make init`"
  final commentPattern =
      RegExp(r'/// Below code will be removed after running `make init`[\s\S]*$', multiLine: true);
  content = content.replaceAll(commentPattern, '');

  // Clean up extra blank lines
  content = content.replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n');

  // Ensure file ends with closing brace if it doesn't
  content = content.trim();
  content += '}\n';

  await sharedViewModelFile.writeAsString(content);
  print('🗑️  Cleaned up shared_view_model.dart');
}

Future<void> _cleanupSharedViewModelTest(String root) async {
  final testFile = File(pathOf(root, 'test/unit_test/ui/shared/shared_view_model_test.dart'));
  if (!await testFile.exists()) return;

  var content = await testFile.readAsString();

  // Remove test groups below comment "/// Below code will be removed after running `make init`"
  final commentPattern =
      RegExp(r'/// Below code will be removed after running `make init`[\s\S]*$', multiLine: true);
  content = content.replaceAll(commentPattern, '');

  // Clean up extra blank lines
  content = content.replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n');

  // Ensure file ends with closing brace if it doesn't
  content = content.trim();
  content += '}\n';

  await testFile.writeAsString(content);
  print('🗑️  Cleaned up shared_view_model_test.dart');
}

Future<void> _cleanupAppColors(String root) async {
  final appColorsFile = File(pathOf(root, 'lib/resource/app_colors.dart'));
  if (!await appColorsFile.exists()) return;

  const newAppColors = '''// ignore_for_file: avoid_hard_coded_colors
import 'package:flutter/material.dart';

import '../index.dart';

class AppColors {
  const AppColors({
    required this.black,
  });

  static late AppColors current;

  final Color black;

  static const defaultAppColor = AppColors(
    black: Colors.black,
  );

  static const darkThemeColor = defaultAppColor;

  static AppColors of(BuildContext context) {
    final appColor = Theme.of(context).appColor;

    current = appColor;

    return current;
  }
}''';

  await appColorsFile.writeAsString(newAppColors);
  print('🗑️  Cleaned up app_colors.dart');
}

Future<void> _cleanupAppRouter(String root) async {
  final appRouterFile = File(pathOf(root, 'lib/navigation/routes/app_router.dart'));
  if (!await appRouterFile.exists()) return;

  var content = await appRouterFile.readAsString();
  final lines = content.split('\n');
  final filteredLines = <String>[];

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    final trimmedLine = line.trim();

    // Skip lines that contain "// remove after running `make init`"
    if (trimmedLine.contains('// remove after running `make init`')) {
      continue;
    }

    filteredLines.add(line);
  }

  content = filteredLines.join('\n');

  await appRouterFile.writeAsString(content);
  print(
      '🗑️  Cleaned up app_router.dart routes (removed lines with "// remove after running `make init`")');
}

Future<void> _cleanupMainViewModel(String root) async {
  final mainViewModelFile = File(pathOf(root, 'lib/ui/page/main/view_model/main_view_model.dart'));
  if (!await mainViewModelFile.exists()) return;

  var content = await mainViewModelFile.readAsString();

  // Remove blocks between "// this block will be removed after running `make init` - START" and "// this block will be removed after running `make init` - END"
  final blockPattern = RegExp(
      r'// this block will be removed after running `make init` - START[\s\S]*?// this block will be removed after running `make init` - END',
      multiLine: true);

  content = content.replaceAll(
      blockPattern, 'FutureOr<void> goToChatPage(AppNotification appNotification) {}');

  await mainViewModelFile.writeAsString(content);
  print(
      '🗑️  Cleaned up main_view_model.dart (removed blocks with "// this block will be removed after running `make init`")');
}

Future<void> _cleanupBaseTestBlocks(String root) async {
  final baseTestFile = File(pathOf(root, 'test/common/base_test.dart'));
  if (!await baseTestFile.exists()) return;

  var content = await baseTestFile.readAsString();

  // Remove blocks between "// this block will be removed after running `make init` - START" and "// this block will be removed after running `make init` - END"
  final blockPattern = RegExp(
      r'// this block will be removed after running `make init` - START[\s\S]*?// this block will be removed after running `make init` - END',
      multiLine: true);

  content = content.replaceAll(blockPattern, '');

  await baseTestFile.writeAsString(content);
  print(
      '🗑️  Cleaned up base_test.dart (removed blocks with "// this block will be removed after running `make init`")');
}

String pathOf(String root, String relative) =>
    root.endsWith('/') ? (root + relative) : (root + '/' + relative);
