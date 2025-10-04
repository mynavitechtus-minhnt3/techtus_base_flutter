import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  final skipError = args.contains('--skip-error');
  final arbFiles = Directory(args[0]).listSync().whereType<File>().map((e) => e.path).toList();

  for (var arbFile in arbFiles) {
    final file = File(arbFile);
    if (await file.exists()) {
      final content = await file.readAsString();
      final Map<String, dynamic> data = json.decode(content);

      final keys = data.keys.toList();
      if (!isSorted(keys)) {
        print('File "$arbFile" is not sorted.');
        if (skipError) {
          print('Skip error mode: Continuing despite unsorted file');
          exit(0);
        }
        exit(1);
      } else {
        print('File "$arbFile" is sorted. 🎉');
        exit(0);
      }
    } else {
      print('File "$arbFile" does not exist.');
    }
  }
}

bool isSorted(List<String> list) {
  for (int i = 1; i < list.length; i++) {
    if (list[i].toLowerCase().compareTo(list[i - 1].toLowerCase()) < 0) {
      return false;
    }
  }
  return true;
}
