import 'dart:convert';
import 'dart:io';

/// Update project files based on JSON config in setting_initial_config.md
/// Usage: dart run tools/dart_tools/lib/init_project.dart

// Constants
const List<String> _iosFlavors = ['Develop', 'Qa', 'Staging', 'Production'];
const List<String> _defaultFlavors = ['develop', 'qa', 'staging', 'production'];
const String _flutterImagePrefix = 'ghcr.io/cirruslabs/flutter:';

// Helper functions for common operations
String? _extractFlutterSdkVersion(Map<String, dynamic> config) {
  // Try common.flutterVersion first
  final common = config['common'] as Map?;
  if (common != null && common['flutterVersion'] != null) {
    return common['flutterVersion'].toString();
  }

  // Try flutter.sdkVersion as fallback
  final flutter = config['flutter'] as Map?;
  if (flutter != null && flutter['sdkVersion'] != null) {
    return flutter['sdkVersion'].toString();
  }

  return null;
}

// Template for setting_initial_config.md
const String _initProjectTemplate = '''Điền giá trị vào JSON bên dưới, sau đó chạy lệnh `make init`

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
''';

Future<bool> _updateVersionInFile(
    String filePath, RegExp pattern, String newVersion, String replacement) async {
  final file = File(filePath);
  if (!await file.exists()) return false;
  var content = await file.readAsString();
  final current = pattern.firstMatch(content);
  final currentVal = current?.group(2); // Get the version group
  if (currentVal != null && currentVal != newVersion) {
    content = content.replaceAllMapped(pattern, (m) {
      final indent = m.group(1) ?? '';
      return replacement.replaceAll('{indent}', indent).replaceAll('{version}', newVersion);
    });
    await file.writeAsString(content);
    return true;
  }
  return false;
}

String _updateProjectCodeInContent(String content, String projectCode) {
  final branchTypes = ['feature', 'bugfix', 'hotfix', 'release'];
  for (final type in branchTypes) {
    // Update regex patterns
    content = content.replaceAll(RegExp("'$type/[A-Z]+'-\*'"), "'$type/$projectCode-*'");
    // Update hardcoded NFT fallback
    content = content.replaceAll("'$type/NFT-*'", "'$type/$projectCode-*'");
  }
  return content;
}

// Create setting_initial_config.md if it doesn't exist
Future<bool> _createInitProjectFileIfNotExists(String projectRoot) async {
  final initPath = pathOf(projectRoot, 'setting_initial_config.md');
  final initFile = File(initPath);

  if (!await initFile.exists()) {
    await initFile.writeAsString(_initProjectTemplate);
    print('✅ Đã tạo file setting_initial_config.md');
    print(
        '🔗 Vui lòng cấu hình dự án tại: \x1b]8;;file://$initPath\x1b\\setting_initial_config.md\x1b]8;;\x1b\\');
    return true;
  }
  return false;
}

// Auto-detect flavors from various config sources
List<String> _detectFlavorsFromConfig(Map<String, dynamic> config) {
  final flavors = <String>{};

  // Check flavors array directly at root level first
  final rootFlavors = config['flavors'] as List?;
  if (rootFlavors != null) {
    flavors.addAll(rootFlavors.cast<String>());
  }

  // Check applicationIds directly in root level
  final applicationIds = config['applicationIds'] as Map?;
  if (applicationIds != null) {
    flavors.addAll(applicationIds.keys.cast<String>());
  }

  // Check bundleIds directly in root level
  final bundleIds = config['bundleIds'] as Map?;
  if (bundleIds != null) {
    flavors.addAll(bundleIds.keys.cast<String>());
  }

  // Check android section
  final android = config['android'] as Map?;
  if (android != null) {
    final androidFlavors = android['flavors'] as List?;
    if (androidFlavors != null) {
      flavors.addAll(androidFlavors.cast<String>());
    }
    final androidAppIds = android['applicationIds'] as Map?;
    if (androidAppIds != null) {
      flavors.addAll(androidAppIds.keys.cast<String>());
    }
  }

  // Check ios section
  final ios = config['ios'] as Map?;
  if (ios != null) {
    final iosBundleIds = ios['bundleIds'] as Map?;
    if (iosBundleIds != null) {
      flavors.addAll(iosBundleIds.keys.cast<String>());
    }
    final iosDisplayNames = ios['displayNames'] as Map?;
    if (iosDisplayNames != null) {
      flavors.addAll(iosDisplayNames.keys.cast<String>());
    }
  }

  // Check envKeys
  final envKeys = config['envKeys'] as Map?;
  if (envKeys != null && envKeys.values.first is Map) {
    flavors.addAll(envKeys.keys.cast<String>());
  }

  return flavors.isEmpty ? _defaultFlavors : flavors.toList()
    ..sort();
}

// Validation functions
List<String> _validateConfig(Map<String, dynamic> config) {
  final errors = <String>[];

  // Required fields
  final common = config['common'] as Map?;
  if (common == null) {
    errors.add('Missing required section: common');
  } else {
    if (!common.containsKey('flutterVersion') || common['flutterVersion'] == null) {
      errors.add('Missing required field: common.flutterVersion');
    }
    if (!common.containsKey('projectCode') || common['projectCode'] == null) {
      errors.add('Missing required field: common.projectCode');
    }
  }

  // Android validation - applicationIds at root level
  final applicationIds = config['applicationIds'] as Map?;
  if (applicationIds != null) {
    if (!applicationIds.containsKey('production')) {
      errors.add('Missing required field: applicationIds.production (used as namespace)');
    }
    for (final entry in applicationIds.entries) {
      if (entry.value == null || entry.value.toString().isEmpty) {
        errors.add('applicationIds.${entry.key} cannot be empty');
      }
    }
  }

  // iOS validation - bundleIds at root level
  final bundleIds = config['bundleIds'] as Map?;
  if (bundleIds != null) {
    for (final entry in bundleIds.entries) {
      if (entry.value != null && entry.value.toString().isNotEmpty) {
        // Only validate non-empty bundleIds
        continue;
      }
    }
  }

  // Fastlane validation
  final fastlane = config['fastlane'] as Map?;
  if (fastlane != null) {
    final requiredFields = ['slackWebhook', 'issuerId', 'firebaseToken', 'mentions'];
    for (final field in requiredFields) {
      if (!fastlane.containsKey(field) ||
          fastlane[field] == null ||
          fastlane[field].toString().isEmpty) {
        errors.add('Missing required field: fastlane.$field');
      }
    }
  }

  // Figma validation (basic design constants)
  final figma = config['figma'] as Map?;
  if (figma != null) {
    final requiredConstants = ['designDeviceWidth', 'designDeviceHeight'];
    for (final constant in requiredConstants) {
      if (!figma.containsKey(constant) || figma[constant] == null) {
        errors.add('Missing required field: figma.$constant');
      }
    }
  }

  return errors;
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

Future<void> main(List<String> args) async {
  final projectRoot = Directory.current.path;
  final inputPath = pathOf(projectRoot, 'setting_initial_config.md');
  final readmePath = pathOf(projectRoot, 'README.md');

  // Create setting_initial_config.md if it doesn't exist
  final wasCreated = await _createInitProjectFileIfNotExists(projectRoot);
  if (wasCreated) {
    // If file was just created, exit to let user configure it first
    print('📝 Vui lòng điền thông tin cấu hình và chạy lại lệnh.');
    return;
  }

  final inputFile = File(inputPath);
  final readmeFile = File(readmePath);

  if (!await inputFile.exists()) {
    stderr.writeln('setting_initial_config.md not found at $inputPath');
    exitCode = 1;
    return;
  }
  if (!await readmeFile.exists()) {
    stderr.writeln('README.md not found at $readmePath');
    exitCode = 1;
    return;
  }

  final inputContent = await inputFile.readAsString();
  final jsonConfigRaw = _extractJsonBlock(inputContent);
  if (jsonConfigRaw == null) {
    stderr.writeln('Could not find valid JSON block in setting_initial_config.md');
    exitCode = 1;
    return;
  }

  Map<String, dynamic> config;
  try {
    config = json.decode(jsonConfigRaw) as Map<String, dynamic>;
  } catch (e) {
    stderr.writeln('❌ Invalid JSON in setting_initial_config.md: $e');
    stderr.writeln('💡 Please check your JSON syntax');
    exitCode = 1;
    return;
  }

  // Validate config
  final validationErrors = _validateConfig(config);
  if (validationErrors.isNotEmpty) {
    stderr.writeln('❌ Configuration validation failed:');
    for (final error in validationErrors) {
      stderr.writeln('  • $error');
    }
    exitCode = 1;
    return;
  }

  print('📖 Config loaded and validated from setting_initial_config.md');

  // Apply changes with error handling - only essential updates
  await _updateWithErrorHandling('README.md', () => _updateReadme(projectRoot, config));
  await _updateWithErrorHandling(
      'Android build.gradle', () => _updateAndroidBuildGradle(projectRoot, config));
  await _updateWithErrorHandling(
      'iOS xcconfig files', () => _updateIosXcconfig(projectRoot, config));
  await _updateWithErrorHandling('Constants file', () => _updateConstants(projectRoot, config));
  await _updateWithErrorHandling(
      'Dart defines files', () => _writeDartDefines(projectRoot, config));
  await _updateWithErrorHandling(
      'Bitbucket pipelines', () => _updateBitbucketPipelines(projectRoot, config));
  await _updateWithErrorHandling('Codemagic YAML', () => _updateCodemagicYaml(projectRoot, config));
  await _updateWithErrorHandling('Jenkinsfile', () => _updateJenkinsfile(projectRoot, config));
  await _updateWithErrorHandling(
      'GitHub workflows', () => _updateGithubWorkflows(projectRoot, config));
  await _updateWithErrorHandling(
      'Lefthook scripts', () => _updateLefthookScripts(projectRoot, config));

  // Skip reading project state back to avoid overwriting user's JSON config
  // final backfill = await _readProjectState(projectRoot, config);
  // final merged = _deepMerge(config, backfill);
  // await _writeInputJson(projectRoot, merged);

  if (exitCode == 0) {
    print('✅ Project updated successfully.');
  } else {
    print('❌ Some updates failed. Please check the errors above.');
  }
}

Future<void> _updateReadme(String root, Map<String, dynamic> config) async {
  final readmeFile = File(pathOf(root, 'README.md'));
  var readme = await readmeFile.readAsString();

  final flutterSdk = _extractFlutterSdkVersion(config);

  if (flutterSdk != null && flutterSdk.isNotEmpty) {
    readme = _replaceBulletValue(
      readme,
      keyPattern: RegExp(r'^-\s+Flutter SDK:\s*.*$', multiLine: true),
      replacement: '- Flutter SDK: $flutterSdk',
    );
  }

  // Remove config JSON block if exists (no longer needed in README)
  readme = _removeConfigJsonBlock(readme);

  // Clean up excessive blank lines
  readme = _cleanupBlankLines(readme);

  await readmeFile.writeAsString(readme);
}

Future<void> _updateAndroidBuildGradle(String root, Map<String, dynamic> config) async {
  final androidFile = File(pathOf(root, 'android/app/build.gradle'));
  if (!await androidFile.exists()) {
    throw Exception('android/app/build.gradle not found');
  }
  var content = await androidFile.readAsString();

  // Get applicationIds from root level first, then from android section as fallback
  var applicationIds = config['applicationIds'] as Map<String, dynamic>?;
  final android = config['android'] as Map<String, dynamic>?;
  if (applicationIds == null && android != null) {
    applicationIds = android['applicationIds'] as Map<String, dynamic>?;
  }

  if (applicationIds != null && applicationIds.isNotEmpty) {
    // Update namespace with production applicationId
    final productionAppId = applicationIds['production']?.toString();
    if (productionAppId != null && productionAppId.isNotEmpty) {
      content = content.replaceAllMapped(RegExp(r'^(\s*)namespace\s*=\s*"[^"]+"', multiLine: true),
          (m) => '${m.group(1)}namespace = "$productionAppId"');

      // Also update defaultConfig applicationId with production applicationId
      content = content.replaceAllMapped(
          RegExp(r'^(\s*)applicationId\s*=\s*"[^"]+"', multiLine: true),
          (m) => '${m.group(1)}applicationId = "$productionAppId"');
    }

    // Update applicationIds for each flavor
    for (final flavor in applicationIds.keys) {
      final appId = applicationIds[flavor]?.toString() ?? '';

      if (appId.isNotEmpty) {
        // Update applicationId for specific flavor
        final flavorPattern = RegExp('$flavor\\s*\\{[\\s\\S]*?\\}');
        content = content.replaceAllMapped(flavorPattern, (match) {
          var flavorContent = match.group(0)!;

          flavorContent = flavorContent.replaceAllMapped(
              RegExp(r'applicationId\s+"[^"]+"'), (m) => 'applicationId "$appId"');

          return flavorContent;
        });
      }
    }
  }

  await androidFile.writeAsString(content);
}

Future<void> _updateIosXcconfig(String root, Map<String, dynamic> config) async {
  // Get bundleIds from root level first, then from ios section as fallback
  var bundleIds = config['bundleIds'] as Map<String, dynamic>?;
  final ios = config['ios'] as Map<String, dynamic>?;
  if (bundleIds == null && ios != null) {
    bundleIds = ios['bundleIds'] as Map<String, dynamic>?;
  }

  // Get applicationIds as fallback for empty bundleIds
  var applicationIds = config['applicationIds'] as Map<String, dynamic>?;
  final android = config['android'] as Map<String, dynamic>?;
  if (applicationIds == null && android != null) {
    applicationIds = android['applicationIds'] as Map<String, dynamic>?;
  }

  if (bundleIds == null && applicationIds == null) return;

  for (final f in _iosFlavors) {
    final file = File(pathOf(root, 'ios/Flutter/$f.xcconfig'));
    if (!await file.exists()) continue;
    var c = await file.readAsString();

    // Map flavor names to config keys
    final flavorKey = f.toLowerCase();

    // Get bundleId, if empty then use applicationId as fallback
    var bundleId = bundleIds?[flavorKey]?.toString() ?? '';
    if (bundleId.isEmpty && applicationIds != null) {
      bundleId = applicationIds[flavorKey]?.toString() ?? '';
    }

    if (bundleId.isNotEmpty) {
      c = c.replaceFirst(RegExp(r'^PRODUCT_BUNDLE_IDENTIFIER=.*', multiLine: true),
          'PRODUCT_BUNDLE_IDENTIFIER=$bundleId');
    }

    await file.writeAsString(c);
  }
}

String _formatConstantValue(String key, dynamic value) {
  // Number types (for figma design constants)
  if (value is num) {
    return value.toString();
  }

  // String types
  if (value is String) {
    return "'${value.replaceAll("'", "\\'")}'";
  }

  // Bool types
  if (value is bool) {
    return value.toString();
  }

  // List types
  if (value is List) {
    final listBody =
        value.map((e) => e is String ? "'${e.replaceAll("'", "\\'")}'" : e.toString()).join(', ');
    return '[$listBody]';
  }

  return value.toString();
}

String _upsertConstantWithSection(String content, String key, dynamic value, String? section) {
  final fieldValue = _formatConstantValue(key, value);

  // Check if field exists - only replace the value part, preserve everything else
  final fieldPattern = RegExp('^(\\s*)static const $key\\s*=\\s*([^;]+);', multiLine: true);
  if (fieldPattern.hasMatch(content)) {
    return content.replaceAllMapped(fieldPattern, (match) {
      final indent = match.group(1) ?? '  ';
      final afterSemicolon = match.group(0)!.substring(match.group(0)!.indexOf(';') + 1);
      return '${indent}static const $key = $fieldValue;$afterSemicolon';
    });
  }

  // Try to find Design section for figma constants
  final sectionPattern = RegExp('^\\s*//\\s*Design\\b.*\$', multiLine: true);
  final sectionMatch = sectionPattern.firstMatch(content);
  if (sectionMatch != null) {
    final afterSectionIndex = sectionMatch.end;
    final rest = content.substring(afterSectionIndex);

    // Find the next section or end of class
    final nextSectionPattern = RegExp('^\\s*//\\s+.+', multiLine: true);
    final nextSectionMatch = nextSectionPattern.firstMatch(rest);
    final insertPos = nextSectionMatch != null
        ? afterSectionIndex + nextSectionMatch.start
        : content.lastIndexOf('}');

    final before = content.substring(0, insertPos);
    final after = content.substring(insertPos);

    final needsLeadingNewline = !before.endsWith('\n') && before.isNotEmpty;
    final needsTrailingNewline = !after.startsWith('\n') && after.isNotEmpty;

    final newField =
        '${needsLeadingNewline ? '\n' : ''}  static const $key = $fieldValue;${needsTrailingNewline ? '\n' : ''}';
    return before + newField + after;
  }

  // Fallback: Insert at the end of class, before closing brace
  final classEndPattern = RegExp(r'^(\s*)\}\s*$', multiLine: true);
  final match = classEndPattern.firstMatch(content);
  if (match != null) {
    final newField = '  static const $key = $fieldValue;\n';
    return content.replaceFirst(classEndPattern, newField + match.group(0)!);
  }

  return content;
}

Future<void> _updateConstants(String root, Map<String, dynamic> config) async {
  final constFile = File(pathOf(root, 'lib/common/constant.dart'));
  if (!await constFile.exists()) {
    throw Exception('lib/common/constant.dart not found');
  }

  var content = await constFile.readAsString();
  final figma = (config['figma'] as Map<String, dynamic>?);
  if (figma == null) return;

  // Only process the figma design constants
  final allowedConstants = {'designDeviceWidth', 'designDeviceHeight'};

  // Process only allowed constants
  figma.forEach((k, v) {
    if (allowedConstants.contains(k)) {
      content = _upsertConstantWithSection(content, k, v, 'Design');
    }
  });

  await constFile.writeAsString(content);
}

Future<void> _writeDartDefines(String root, Map<String, dynamic> config) async {
  // Auto-detect flavors from various config sources
  final flavors = _detectFlavorsFromConfig(config);

  final dir = Directory(pathOf(root, 'dart_defines'));
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  for (final flavor in flavors) {
    final map = <String, dynamic>{
      'FLAVOR': flavor,
    };

    final file = File(pathOf(root, 'dart_defines/$flavor.json'));
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(map));
  }
}

Future<void> _updateBitbucketPipelines(String root, Map<String, dynamic> config) async {
  final file = File(pathOf(root, 'bitbucket-pipelines.yml'));
  if (!await file.exists()) return;
  var c = await file.readAsString();

  final flutterSdk = _extractFlutterSdkVersion(config);
  if (flutterSdk != null && flutterSdk.isNotEmpty) {
    c = c.replaceFirst(
        RegExp(r'^image:\s+ghcr\.io/cirruslabs/flutter:\d+\.\d+\.\d+', multiLine: true),
        'image: $_flutterImagePrefix$flutterSdk');
  }

  // Get project code from common first, then lefthook as fallback
  var projectCode = '';
  final common = config['common'] as Map<String, dynamic>?;
  if (common != null && common['projectCode'] != null) {
    projectCode = common['projectCode'].toString();
  }

  if (projectCode.isNotEmpty) {
    c = _updateProjectCodeInContent(c, projectCode);
  }

  await file.writeAsString(c);
}

Future<void> _updateCodemagicYaml(String root, Map<String, dynamic> config) async {
  final file = File(pathOf(root, 'codemagic.yaml'));
  if (!await file.exists()) return;

  final flutterSdk = _extractFlutterSdkVersion(config);

  if (flutterSdk != null && flutterSdk.isNotEmpty) {
    await _updateVersionInFile(
      file.path,
      RegExp(r'^(\s*)flutter:\s*(\d+\.\d+\.\d+)', multiLine: true),
      flutterSdk,
      '{indent}flutter: {version}',
    );
  }
}

Future<void> _updateJenkinsfile(String root, Map<String, dynamic> config) async {
  final file = File(pathOf(root, 'Jenkinsfile'));
  if (!await file.exists()) return;

  final flutterSdk = _extractFlutterSdkVersion(config);
  if (flutterSdk != null && flutterSdk.isNotEmpty) {
    var content = await file.readAsString();
    final current = RegExp(r'ghcr\.io/cirruslabs/flutter:(\d+\.\d+\.\d+)').firstMatch(content);
    final currentVal = current?.group(1);
    if (currentVal != null && currentVal != flutterSdk) {
      content = content.replaceAll(
          RegExp(r"ghcr\.io/cirruslabs/flutter:\d+\.\d+\.\d+"), '$_flutterImagePrefix$flutterSdk');
      await file.writeAsString(content);
    }
  }
}

Future<void> _updateGithubWorkflows(String root, Map<String, dynamic> config) async {
  final dir = Directory(pathOf(root, '.github/workflows'));
  if (!await dir.exists()) return;
  final flutterSdk = _extractFlutterSdkVersion(config);
  if (flutterSdk == null || flutterSdk.isEmpty) return;

  await for (final e in dir.list(recursive: false, followLinks: false)) {
    if (e is! File) continue;
    if (!e.path.endsWith('.yaml') && !e.path.endsWith('.yml')) continue;

    final updated = await _updateVersionInFile(
      e.path,
      RegExp(r'^(\s*)FLUTTER_VERSION:\s*"(\d+\.\d+\.\d+)"', multiLine: true),
      flutterSdk,
      '{indent}FLUTTER_VERSION: "{version}"',
    );

    if (updated) {
      // File already updated by _updateVersionInFile
    }
  }
}

Future<void> _updateLefthookScripts(String root, Map<String, dynamic> config) async {
  // Get project code from common section
  final common = config['common'] as Map<String, dynamic>?;
  if (common == null || common['projectCode'] == null) return;

  final projectCode = common['projectCode'].toString();
  if (projectCode.isEmpty) return;

  // Update commit-msg script
  final commitMsgFile = File(pathOf(root, '.lefthook/commit-msg/commit-msg.sh'));
  if (await commitMsgFile.exists()) {
    var content = await commitMsgFile.readAsString();

    // Replace any existing project code with new one
    // Pattern: [PROJECTCODE-digits] - matches any uppercase letters/numbers before dash
    content = content.replaceAllMapped(
      RegExp(r'([A-Z0-9]+)(-\\d\+|\-\d+|\-\[0\-9\]\+)'),
      (match) => '$projectCode${match.group(2)}',
    );

    await commitMsgFile.writeAsString(content);
  }

  // Update pre-commit script
  final preCommitFile = File(pathOf(root, '.lefthook/pre-commit/pre-commit.sh'));
  if (await preCommitFile.exists()) {
    var content = await preCommitFile.readAsString();

    // Replace any existing project code with new one
    // Pattern: [PROJECTCODE-digits] - matches any uppercase letters/numbers before dash
    content = content.replaceAllMapped(
      RegExp(r'([A-Z0-9]+)(-\\d\+|\-\d+|\-\[0\-9\]\+)'),
      (match) => '$projectCode${match.group(2)}',
    );

    await preCommitFile.writeAsString(content);
  }
}

String? _extractJsonBlock(String content) {
  final regex = RegExp(r'```json\s*([\s\S]*?)\s*```', multiLine: true);
  final match = regex.firstMatch(content);
  if (match == null) return null;

  var jsonContent = match.group(1)!;

  // Fix systemUiOverlay multiline strings
  jsonContent = _fixMultilineStrings(jsonContent);

  // Fix JSON comments
  jsonContent = _fixJsonComments(jsonContent);

  return jsonContent;
}

String _fixMultilineStrings(String content) {
  // Fix systemUiOverlay multiline SystemUiOverlayStyle
  final systemUiPattern =
      RegExp(r'"systemUiOverlay":\s*"SystemUiOverlayStyle\(\s*([\s\S]*?)\s*\)"', multiLine: true);

  return content.replaceAllMapped(systemUiPattern, (match) {
    final innerContent = match.group(1)!.trim();
    // Remove newlines and extra spaces, keep single spaces
    final cleaned = innerContent.replaceAll(RegExp(r'\s+'), ' ');
    return '"systemUiOverlay": "SystemUiOverlayStyle($cleaned)"';
  });
}

String pathOf(String root, String relative) =>
    root.endsWith('/') ? (root + relative) : (root + '/' + relative);

String _replaceBulletValue(String input,
    {required RegExp keyPattern, required String replacement}) {
  if (keyPattern.hasMatch(input)) {
    return input.replaceFirst(keyPattern, replacement);
  }
  final lines = input.split('\n');
  final reqIndex = lines.indexWhere((l) => l.trim() == '### Requirements');
  if (reqIndex != -1) {
    lines.insert(reqIndex + 1, replacement.trimRight());
    return lines.join('\n');
  }
  return input;
}

String _cleanupBlankLines(String content) {
  final lines = content.split('\n');
  final cleaned = <String>[];
  bool lastWasBlank = false;

  for (final line in lines) {
    final isBlank = line.trim().isEmpty;

    if (isBlank) {
      if (!lastWasBlank) {
        cleaned.add(line);
      }
      lastWasBlank = true;
    } else {
      cleaned.add(line);
      lastWasBlank = false;
    }
  }

  return cleaned.join('\n');
}

// keep helper for potential future use

String _removeConfigJsonBlock(String readme) {
  const startMarker = '<!-- CONFIG_INPUT_START -->';
  const endMarker = '<!-- CONFIG_INPUT_END -->';
  if (readme.contains(startMarker) && readme.contains(endMarker)) {
    final pattern = RegExp('$startMarker[\\s\\S]*?$endMarker', multiLine: true);
    // Chỉ loại bỏ block cấu hình, KHÔNG trim hoặc chỉnh sửa dòng trống xung quanh
    return readme.replaceFirst(pattern, '');
  }
  return readme;
}

// Fix JSON parsing for files with comments
String _fixJsonComments(String jsonContent) {
  // Remove single line comments
  var lines = jsonContent.split('\n');
  lines = lines.map((line) {
    final commentIndex = line.indexOf('//');
    if (commentIndex != -1) {
      // Check if // is inside a string
      final beforeComment = line.substring(0, commentIndex);
      final quotes = beforeComment.split('"').length - 1;
      if (quotes % 2 == 0) {
        // Even number of quotes means // is outside string
        return beforeComment.trimRight();
      }
    }
    return line;
  }).toList();

  // Remove trailing commas
  var result = lines.join('\n');
  result = result.replaceAll(RegExp(r',\s*}'), '}');
  result = result.replaceAll(RegExp(r',\s*]'), ']');

  return result;
}
