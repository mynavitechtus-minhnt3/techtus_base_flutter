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
const String _initProjectTemplate = '''Fill in the values below, then run `make init` command

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
      // for now only setup CD for QA environment
      "qa": "1:598926766937:android:9592c6941fa17be8aed248"
    },
    "appStoreIds": {
      // for now only setup CD for QA environment
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
  // if empty, will use the same values as applicationIds
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
    print('✅ Created setting_initial_config.md file');
    print(
        '🔗 Please configure project at: \x1b]8;;file://$initPath\x1b\\setting_initial_config.md\x1b]8;;\x1b\\');
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
    print('📝 Please fill in the configuration information and run the command again.');
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
  await _updateWithErrorHandling(
      'Environment config', () => _updateEnvDefault(projectRoot, config));
  await _updateWithErrorHandling('Fastlane files', () => _updateFastlaneFiles(projectRoot, config));
  await _updateWithErrorHandling(
      'Android Manifest', () => _updateAndroidManifest(projectRoot, config));
  await _updateWithErrorHandling(
      'Local Push Notification', () => _updateLocalPushNotification(projectRoot, config));
  await _updateWithErrorHandling(
      'MainActivity package', () => _updateMainActivityPackage(projectRoot, config));
  await _updateWithErrorHandling('Export Options', () => _updateExportOptions(projectRoot, config));

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

  // Update Google Play package name with staging applicationId
  final applicationIds = config['applicationIds'] as Map<String, dynamic>?;
  if (applicationIds != null && applicationIds['staging'] != null) {
    var content = await file.readAsString();
    final stagingAppId = applicationIds['staging'].toString();

    // Update the Google Play build number command
    content = content.replaceAllMapped(
      RegExp(
          r"LATEST_GOOGLE_PLAY_BUILD_NUMBER=\$\(google-play get-latest-build-number --package-name '[^']+'\)"),
      (match) =>
          "LATEST_GOOGLE_PLAY_BUILD_NUMBER=\$(google-play get-latest-build-number --package-name '$stagingAppId')",
    );

    await file.writeAsString(content);
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

Future<void> _updateEnvDefault(String root, Map<String, dynamic> config) async {
  // Get fastlane section
  final fastlane = config['fastlane'] as Map<String, dynamic>?;
  if (fastlane == null) return;

  final envFile = File(pathOf(root, '.env.default'));

  // Create the file content with fastlane variables
  final envContent = <String>[];

  // Add header comment
  envContent.add('# Environment variables for Fastlane');
  envContent.add('# This file contains default values for CI/CD configuration');
  envContent.add('');

  // Add fastlane variables
  if (fastlane['slackWebhook'] != null) {
    envContent.add('SLACK_WEBHOOK=${fastlane['slackWebhook']}');
  }

  if (fastlane['issuerId'] != null) {
    envContent.add('ISSUER_ID=${fastlane['issuerId']}');
  }

  if (fastlane['firebaseToken'] != null) {
    envContent.add('FIREBASE_TOKEN=${fastlane['firebaseToken']}');
  }

  if (fastlane['mentions'] != null) {
    envContent.add('MENTIONS=${fastlane['mentions']}');
  }

  envContent.add('MESSAGE=Xin các anh chị tester nhẹ tay giúp!');
  envContent.add('DEV_FLAVOR=develop');
  envContent.add('QA_FLAVOR=qa');
  envContent.add('STG_FLAVOR=staging');

  // Write to file
  await envFile.writeAsString(envContent.join('\n') + '\n');
}

Future<void> _updateFastlaneFiles(String root, Map<String, dynamic> config) async {
  // Get fastlane section
  final fastlane = config['fastlane'] as Map<String, dynamic>?;
  if (fastlane == null) return;

  // Update Android Fastfile
  await _updateAndroidFastfile(root, fastlane);

  // Update iOS Fastfile
  await _updateIosFastfile(root, fastlane);
}

Future<void> _updateAndroidFastfile(String root, Map<String, dynamic> fastlane) async {
  final fastfileAndroid = File(pathOf(root, 'android/fastlane/Fastfile'));
  if (!await fastfileAndroid.exists()) return;

  var content = await fastfileAndroid.readAsString();

  // Update Firebase App IDs from firebaseAppIds
  final firebaseAppIds = fastlane['firebaseAppIds'] as Map?;
  if (firebaseAppIds != null) {
    firebaseAppIds.forEach((flavor, appId) {
      if (appId != null) {
        // Map flavor names to variable names used in Fastfile
        String varName;
        switch (flavor.toString().toLowerCase()) {
          case 'develop':
            varName = 'DEV_APP_ID';
            break;
          case 'qa':
            varName = 'QA_APP_ID';
            break;
          case 'staging':
            varName = 'STG_APP_ID';
            break;
          default:
            varName = '${flavor.toString().toUpperCase()}_APP_ID';
        }

        // Update variable assignment: DEV_APP_ID = "value"
        content = content.replaceAllMapped(
          RegExp('$varName\\s*=\\s*"[^"]*"'),
          (match) => '$varName = "$appId"',
        );
      }
    });
  }

  await fastfileAndroid.writeAsString(content);
}

Future<void> _updateIosFastfile(String root, Map<String, dynamic> fastlane) async {
  final fastfileIos = File(pathOf(root, 'ios/fastlane/Fastfile'));
  if (!await fastfileIos.exists()) return;

  var content = await fastfileIos.readAsString();

  // Update App Store IDs from appStoreIds
  final appStoreIds = fastlane['appStoreIds'] as Map?;
  if (appStoreIds != null) {
    appStoreIds.forEach((flavor, appId) {
      if (appId != null) {
        // Map flavor names to variable names used in Fastfile
        String varName;
        switch (flavor.toString().toLowerCase()) {
          case 'develop':
            varName = 'DEV_APP_STORE_ID';
            break;
          case 'qa':
            varName = 'QA_APP_STORE_ID';
            break;
          case 'staging':
            varName = 'STG_APP_STORE_ID';
            break;
          default:
            varName = '${flavor.toString().toUpperCase()}_APP_STORE_ID';
        }

        // Update variable assignment: DEV_APP_STORE_ID = "value"
        content = content.replaceAllMapped(
          RegExp('$varName\\s*=\\s*"[^"]*"'),
          (match) => '$varName = "$appId"',
        );
      }
    });
  }

  await fastfileIos.writeAsString(content);
}

Future<void> _updateAndroidManifest(String root, Map<String, dynamic> config) async {
  final manifestFile = File(pathOf(root, 'android/app/src/main/AndroidManifest.xml'));
  if (!await manifestFile.exists()) return;

  final applicationIds = config['applicationIds'] as Map<String, dynamic>?;
  if (applicationIds == null || applicationIds['production'] == null) return;

  final productionAppId = applicationIds['production'].toString();
  var content = await manifestFile.readAsString();

  // Update package attribute in manifest tag
  content = content.replaceAllMapped(
    RegExp(r'package="[^"]*"'),
    (match) => 'package="$productionAppId"',
  );

  // Update notification channel ID
  content = content.replaceAllMapped(
    RegExp(
        r'android:name="com\.google\.firebase\.messaging\.default_notification_channel_id"\s*android:value="[^"]*"'),
    (match) =>
        'android:name="com.google.firebase.messaging.default_notification_channel_id"\n            android:value="$productionAppId"',
  );

  await manifestFile.writeAsString(content);
}

Future<void> _updateLocalPushNotification(String root, Map<String, dynamic> config) async {
  final notificationFile =
      File(pathOf(root, 'lib/common/helper/local_push_notification_helper.dart'));
  if (!await notificationFile.exists()) return;

  final applicationIds = config['applicationIds'] as Map<String, dynamic>?;
  if (applicationIds == null || applicationIds['production'] == null) return;

  final productionAppId = applicationIds['production'].toString();
  var content = await notificationFile.readAsString();

  // Update _channelId constant
  content = content.replaceAllMapped(
    RegExp(r"static const _channelId = '[^']*';"),
    (match) => "static const _channelId = '$productionAppId';",
  );

  await notificationFile.writeAsString(content);
}

Future<void> _updateMainActivityPackage(String root, Map<String, dynamic> config) async {
  final applicationIds = config['applicationIds'] as Map<String, dynamic>?;
  if (applicationIds == null || applicationIds['production'] == null) return;

  final productionAppId = applicationIds['production'].toString();

  // Update MainActivity.kt package and file path
  final oldMainActivityPath =
      pathOf(root, 'android/app/src/main/kotlin/jp/flutter/app/MainActivity.kt');
  final newMainActivityPath = pathOf(
      root, 'android/app/src/main/kotlin/${productionAppId.replaceAll('.', '/')}/MainActivity.kt');

  // Create new directory structure first
  final newDir = Directory(
      pathOf(root, 'android/app/src/main/kotlin/${productionAppId.replaceAll('.', '/')}'));
  await newDir.create(recursive: true);

  final oldMainActivityFile = File(oldMainActivityPath);
  final newMainActivityFile = File(newMainActivityPath);

  if (await oldMainActivityFile.exists()) {
    // Read content from old file
    var content = await oldMainActivityFile.readAsString();

    // Write to new location first (without updating package yet)
    await newMainActivityFile.writeAsString(content);

    // Delete old file
    await oldMainActivityFile.delete();
  }

  // Now update the package in the new file
  if (await newMainActivityFile.exists()) {
    var content = await newMainActivityFile.readAsString();

    // Update package declaration - handle both jp.flutter.app and any other package
    if (content.contains('package jp.flutter.app')) {
      content = content.replaceAll('package jp.flutter.app', 'package $productionAppId');
    } else {
      // Generic regex for any package
      content = content.replaceAllMapped(
        RegExp(r'package [a-zA-Z0-9_.]+'),
        (match) => 'package $productionAppId',
      );
    }

    await newMainActivityFile.writeAsString(content);
  } else {
    // If neither file exists, create new one with correct package
    final content = '''package $productionAppId

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
//        println(BuildConfig.API_KEY)
//        println(BuildConfig.API_SECRET)
    }
}''';

    await newMainActivityFile.writeAsString(content);
  }
}

Future<void> _updateExportOptions(String root, Map<String, dynamic> config) async {
  final exportOptionsFile = File(pathOf(root, 'ios/exportOptions.plist'));
  if (!await exportOptionsFile.exists()) return;

  final bundleIds = config['bundleIds'] as Map<String, dynamic>?;
  if (bundleIds == null || bundleIds['production'] == null) return;

  final productionBundleId = bundleIds['production'].toString();
  var content = await exportOptionsFile.readAsString();

  // Update bundle identifier in provisioningProfiles
  content = content.replaceAllMapped(
    RegExp(r'<key>[^<]*</key>\s*<string>[^<]*</string>(?=\s*</dict>)'),
    (match) => '<key>$productionBundleId</key>\n\t\t<string>distribution_flutter_codebase</string>',
  );

  await exportOptionsFile.writeAsString(content);
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
    // Only remove config block, DON'T trim or modify surrounding blank lines
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
