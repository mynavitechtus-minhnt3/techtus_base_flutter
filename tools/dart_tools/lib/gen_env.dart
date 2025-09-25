// ignore_for_file: avoid_print

import 'dart:io';

void main(List<String> args) {
  // Create setting_initial_config.md if it doesn't exist
  _createInitProjectFile(args[0]);

  // Create dart_defines files
  _createJsonFile(args[0], 'develop');
  _createJsonFile(args[0], 'qa');
  _createJsonFile(args[0], 'staging');
  _createJsonFile(args[0], 'production');
}

void _createInitProjectFile(String folder) {
  File file = File('$folder/setting_initial_config.md');
  if (!file.existsSync()) {
    file.createSync(recursive: true);
    file.writeAsStringSync('''Điền giá trị vào JSON bên dưới, sau đó chạy lệnh `make init`

```json
{
  "common": {
    "flutterVersion": "3.35.1",
    "projectCode": "NFT"
  },
  "fastlane": {
    "slackWebhook": "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK",
    "issuerId": "69a6de12-xxxx-xxxx-xxxx-12ef3456c789",
    "firebaseToken": "1//0000000000000000000000000000000000000000",
    "mentions": "@minhnt3",
    "firebaseAppIds": {
      // trước mắt chỉ cần setup CD cho môi trường QA
      "qa": "1:598926766937:android:9592c6941fa17be8aed248"
    },
    "appStoreIds": {
      // trước mắt chỉ cần setup CD cho môi trường QA
      "qa": "6478853077"
    }
  },
  "figma": {
    "designDeviceWidth": 375.0,
    "designDeviceHeight": 812.0
  },
  "applicationIds": {
    "develop": "jp.flutter.app",
    "qa": "jp.flutter.app",
    "staging": "jp.flutter.app",
    "production": "jp.flutter.app"
  },
  // nếu để trống thì sẽ lấy giá trị giống với applicationIds
  "bundleIds": {
    "develop": "",
    "qa": "",
    "staging": "",
    "production": ""
  }
}
```
''');
    print('✅ File setting_initial_config.md created');
  } else {
    print('!!! File setting_initial_config.md already exists !!!');
  }
}

void _createJsonFile(String folder, String filename) {
  File file = File('$folder/dart_defines/$filename.json');
  if (!file.existsSync()) {
    file.createSync(recursive: true);
    file.writeAsStringSync('''{
  "FLAVOR": "$filename"
}
''');
    print('✅ File $filename.json created');
  } else {
    print('!!! File $filename.json already exists !!!');
  }
}
