import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mime/mime.dart';

import '../../index.dart';

class FileUtil {
  static String? defaultDir;

  static Future<File?> getImageFileFromUrl(String imageUrl) async {
    try {
      return DefaultCacheManager().getSingleFile(imageUrl);
    } catch (e) {
      Log.e('Error fetching image from URL: $e');

      return null;
    }
  }

  static String? getMimeType(String filePath) {
    return lookupMimeType(filePath);
  }

  static bool isFolder(String filePath) {
    return FileSystemEntity.isDirectorySync(filePath);
  }

  static bool deleteFile({
    required String filePath,
    bool recursive = false,
  }) {
    try {
      File(filePath).deleteSync(recursive: recursive);

      return true;
    } catch (e) {
      Log.e('Error deleting file: $e');
    }

    return false;
  }
}
