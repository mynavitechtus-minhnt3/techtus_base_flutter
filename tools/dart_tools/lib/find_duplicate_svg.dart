import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';

void main(List<String> args) async {
  final skipError = args.contains('--skip-error');
  if (args.isEmpty) {
    print('Usage: dart run tool/find_duplicate_svg.dart <images_folder> [--skip-error]');
    exit(1);
  }
  final folder = Directory(args.first);

  if (!await folder.exists()) {
    print('Folder not found: ${folder.path}');
    if (skipError) {
      print('Skip error mode: Continuing despite folder not found');
      exit(0);
    }
    exit(1);
  }

  final Map<String, List<String>> hashToFiles = {};

  await for (final file in folder.list(recursive: true)) {
    if (file is File && file.path.endsWith('.svg')) {
      final content = await file.readAsString();
      final normalized = content.replaceAll(RegExp(r'\s+'), '');
      final hash = sha256.convert(utf8.encode(normalized)).toString();
      hashToFiles.putIfAbsent(hash, () => []).add(file.path);
    }
  }

  bool hasDuplicate = false;
  for (final entry in hashToFiles.entries) {
    if (entry.value.length > 1) {
      hasDuplicate = true;
      print('\n🔶 Duplicate SVG files (same content):');
      for (final path in entry.value) {
        print('  - $path');
      }
    }
  }

  if (!hasDuplicate) {
    print('✅ No duplicate SVG content found!');
    exit(0);
  } else {
    if (skipError) {
      print('Skip error mode: Continuing despite duplicate SVG files found');
      exit(0);
    }
    exit(1);
  }
}
