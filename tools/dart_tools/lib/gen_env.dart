// ignore_for_file: avoid_print

import 'dart:io';

void main(List<String> args) {
  _createJsonFile(args[0], 'develop');
  _createJsonFile(args[0], 'qa');
  _createJsonFile(args[0], 'staging');
  _createJsonFile(args[0], 'production');
}

void _createJsonFile(String folder, String filename) {
  File file = File('$folder/dart_defines/$filename.json');
  if (!file.existsSync()) {
    file.createSync(recursive: true);
    file.writeAsStringSync('''{
  "FLAVOR": "$filename"
}
''');
    print('File $filename.json created');
  } else {
    print('!!! File $filename.json already exists !!!');
  }
}
