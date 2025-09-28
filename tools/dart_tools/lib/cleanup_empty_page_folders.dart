// ignore_for_file: avoid_print

import 'dart:io';

/// Clean up empty page folders or folders containing only .freezed.dart files
/// Usage: dart run tools/dart_tools/lib/cleanup_empty_page_folders.dart [path] [--dry-run]
/// Default path: lib/ui/page
/// --dry-run: Show what would be deleted without actually deleting

void main(List<String> args) async {
  final bool dryRun = args.contains('--dry-run');
  final String targetPath = args.where((arg) => !arg.startsWith('--')).isNotEmpty
      ? args.where((arg) => !arg.startsWith('--')).first
      : 'lib/ui/page';

  print('🧹 ${dryRun ? 'Analyzing' : 'Cleaning up'} empty folders in: $targetPath');
  if (dryRun) {
    print('🔍 Dry run mode - no files will be deleted');
  }

  final targetDir = Directory(targetPath);
  if (!await targetDir.exists()) {
    print('❌ Path does not exist: $targetPath');
    exit(1);
  }

  await _cleanupEmptyFolders(targetPath, dryRun: dryRun);
  print('✅ ${dryRun ? 'Analysis' : 'Cleanup'} completed');
}

Future<void> _cleanupEmptyFolders(String path, {bool dryRun = false}) async {
  final directory = Directory(path);

  await for (final entity in directory.list()) {
    if (entity is Directory) {
      final folderName = entity.path.split('/').last;

      // Skip if it's not a directory or is a special file
      if (folderName.startsWith('.')) continue;

      // Recursively clean subdirectories first
      await _cleanupEmptyFolders(entity.path, dryRun: dryRun);

      // Check if folder should be deleted
      if (await _shouldDeleteFolder(entity)) {
        if (dryRun) {
          print('🗑️  [DRY RUN] Would delete: ${entity.path}');
        } else {
          try {
            await entity.delete(recursive: true);
            print('🗑️  Deleted empty/freezed-only folder: ${entity.path}');
          } catch (e) {
            print('❌ Failed to delete ${entity.path}: $e');
          }
        }
      }
    }
  }
}

Future<bool> _shouldDeleteFolder(Directory folder) async {
  final List<FileSystemEntity> contents = [];

  try {
    await for (final entity in folder.list(recursive: true)) {
      // Only count actual files, not directories
      if (entity is File) {
        contents.add(entity);
      }
    }
  } catch (e) {
    print('❌ Error reading folder ${folder.path}: $e');
    return false;
  }

  // Delete if completely empty
  if (contents.isEmpty) {
    print('📁 Found empty folder: ${folder.path}');
    return true;
  }

  // Delete if only contains .freezed.dart files
  final bool onlyFreezedFiles = contents.every((entity) {
    if (entity is File) {
      return entity.path.endsWith('.freezed.dart');
    }
    return false;
  });

  if (onlyFreezedFiles) {
    print('🧊 Found folder with only .freezed.dart files: ${folder.path}');
    print('   Files: ${contents.map((e) => e.path.split('/').last).join(', ')}');
    return true;
  }

  // Keep folder if it has other files
  return false;
}
