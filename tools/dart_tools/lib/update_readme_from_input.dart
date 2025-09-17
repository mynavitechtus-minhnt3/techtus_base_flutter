import 'dart:convert';
import 'dart:io';

/// Update project files based on JSON config in README.input.md
/// Usage: dart run tools/dart_tools/lib/update_readme_from_input.dart

// Constants
const List<String> _iosFlavors = ['Develop', 'Qa', 'Staging', 'Production'];
const List<String> _defaultFlavors = ['develop', 'qa', 'staging', 'production'];
const String _flutterImagePrefix = 'ghcr.io/cirruslabs/flutter:';

// Helper functions for common operations
String? _extractFlutterSdkVersion(Map<String, dynamic> config) {
  return (config['flutter'] as Map?)?['sdkVersion']?.toString();
}

String? _extractCocoapodsVersion(Map<String, dynamic> config) {
  return (config['cocoapods'] as Map?)?['version']?.toString();
}

Future<String?> _readVersionFromFile(String filePath, RegExp pattern) async {
  final file = File(filePath);
  if (!await file.exists()) return null;
  final content = await file.readAsString();
  final match = pattern.firstMatch(content);
  return match?.group(1);
}

Future<String?> _readFlutterVersionFromWorkflows(String root) async {
  final dir = Directory(pathOf(root, '.github/workflows'));
  if (!await dir.exists()) return null;
  await for (final e in dir.list()) {
    if (e is! File) continue;
    final content = await e.readAsString();
    final m = RegExp(r'^\s*FLUTTER_VERSION:\s*"(\d+\.\d+\.\d+)"', multiLine: true).firstMatch(content);
    if (m != null) return m.group(1);
  }
  return null;
}

Future<String?> _readFlutterVersionFromCodemagic(String root) async {
  return _readVersionFromFile(
    pathOf(root, 'codemagic.yaml'),
    RegExp(r'^\s*flutter:\s*(\d+\.\d+\.\d+)', multiLine: true),
  );
}

Future<String?> _readCocoapodsFromCodemagic(String root) async {
  return _readVersionFromFile(
    pathOf(root, 'codemagic.yaml'),
    RegExp(r'^\s*cocoapods:\s*(\d+\.\d+\.\d+)', multiLine: true),
  );
}

Future<bool> _updateVersionInFile(String filePath, RegExp pattern, String newVersion, String replacement) async {
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


// Auto-detect flavors from various config sources
List<String> _detectFlavorsFromConfig(Map<String, dynamic> config) {
  final flavors = <String>{};
  
  // Check Android
  final android = config['android'] as Map?;
  if (android != null) {
    flavors.addAll((android['applicationIds'] as Map?)?.keys.cast<String>() ?? []);
    flavors.addAll((android['appNames'] as Map?)?.keys.cast<String>() ?? []);
  }
  
  // Check iOS
  final ios = config['ios'] as Map?;
  if (ios != null) {
    flavors.addAll((ios['bundleIds'] as Map?)?.keys.cast<String>() ?? []);
    flavors.addAll((ios['displayNames'] as Map?)?.keys.cast<String>() ?? []);
  }
  
  // Check envKeys
  final envKeys = config['envKeys'] as Map?;
  if (envKeys != null && envKeys.values.first is Map) {
    flavors.addAll(envKeys.keys.cast<String>());
  }
  
  return flavors.isEmpty ? _defaultFlavors : flavors.toList()..sort();
}

// Validation functions
List<String> _validateConfig(Map<String, dynamic> config) {
  final errors = <String>[];
  
  // Required fields
  if (!config.containsKey('projectName') || config['projectName'] == null) {
    errors.add('Missing required field: projectName');
  }
  
  if (!config.containsKey('description') || config['description'] == null) {
    errors.add('Missing required field: description');
  }
  
  // Android validation
  final android = config['android'] as Map?;
  if (android != null) {
    if (!android.containsKey('versionName') || android['versionName'] == null) {
      errors.add('Missing required field: android.versionName');
    }
    if (!android.containsKey('versionCode') || android['versionCode'] == null) {
      errors.add('Missing required field: android.versionCode');
    }
    
    // Validate applicationIds
    final applicationIds = android['applicationIds'] as Map?;
    if (applicationIds != null) {
      for (final entry in applicationIds.entries) {
        if (entry.value == null || entry.value.toString().isEmpty) {
          errors.add('android.applicationIds.${entry.key} cannot be empty');
        }
      }
    }
    
    // Validate appNames
    final appNames = android['appNames'] as Map?;
    if (appNames != null) {
      for (final entry in appNames.entries) {
        if (entry.value == null || entry.value.toString().isEmpty) {
          errors.add('android.appNames.${entry.key} cannot be empty');
        }
      }
    }
  }
  
  // iOS validation
  final ios = config['ios'] as Map?;
  if (ios != null) {
    // Validate bundleIds
    final bundleIds = ios['bundleIds'] as Map?;
    if (bundleIds != null) {
      for (final entry in bundleIds.entries) {
        if (entry.value == null || entry.value.toString().isEmpty) {
          errors.add('ios.bundleIds.${entry.key} cannot be empty');
        }
      }
    }
    
    // Validate displayNames
    final displayNames = ios['displayNames'] as Map?;
    if (displayNames != null) {
      for (final entry in displayNames.entries) {
        if (entry.value == null || entry.value.toString().isEmpty) {
          errors.add('ios.displayNames.${entry.key} cannot be empty');
        }
      }
    }
  }
  
  // Validate flavor consistency
  final detectedFlavors = _detectFlavorsFromConfig(config);
  if (detectedFlavors.length > 1) {
    // Check if all flavor-specific configs have the same flavors
    final androidFlavors = <String>{};
    final iosFlavors = <String>{};
    final envFlavors = <String>{};
    
    if (android != null) {
      androidFlavors.addAll((android['applicationIds'] as Map?)?.keys.cast<String>() ?? []);
      androidFlavors.addAll((android['appNames'] as Map?)?.keys.cast<String>() ?? []);
    }
    
    if (ios != null) {
      iosFlavors.addAll((ios['bundleIds'] as Map?)?.keys.cast<String>() ?? []);
      iosFlavors.addAll((ios['displayNames'] as Map?)?.keys.cast<String>() ?? []);
    }
    
    final envKeys = config['envKeys'] as Map?;
    if (envKeys != null && envKeys.values.first is Map) {
      envFlavors.addAll(envKeys.keys.cast<String>());
    }
    
    // Check consistency
    if (androidFlavors.isNotEmpty && iosFlavors.isNotEmpty && 
        !androidFlavors.difference(iosFlavors).isEmpty) {
      errors.add('Flavor mismatch: Android flavors (${androidFlavors.join(', ')}) do not match iOS flavors (${iosFlavors.join(', ')})');
    }
    
    if (envFlavors.isNotEmpty && detectedFlavors.length > 1) {
      final missingFlavors = detectedFlavors.where((f) => !envFlavors.contains(f)).toList();
      if (missingFlavors.isNotEmpty) {
        errors.add('Missing envKeys for flavors: ${missingFlavors.join(', ')}');
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
  final inputPath = pathOf(projectRoot, 'README.input.md');
  final readmePath = pathOf(projectRoot, 'README.md');

  final inputFile = File(inputPath);
  final readmeFile = File(readmePath);

  if (!await inputFile.exists()) {
    stderr.writeln('README.input.md not found at $inputPath');
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
    stderr.writeln('Could not find valid JSON block in README.input.md');
    exitCode = 1;
    return;
  }

  Map<String, dynamic> config;
  try {
    config = json.decode(jsonConfigRaw) as Map<String, dynamic>;
  } catch (e) {
    stderr.writeln('❌ Invalid JSON in README.input.md: $e');
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

  print('📖 Config loaded and validated from README.input.md');

  // Apply changes with error handling
  await _updateWithErrorHandling('README.md', () => _updateReadme(projectRoot, config));
  await _updateWithErrorHandling('Android build.gradle', () => _updateAndroidBuildGradle(projectRoot, config));
  await _updateWithErrorHandling('iOS xcconfig files', () => _updateIosXcconfig(projectRoot, config));
  await _updateWithErrorHandling('Constants file', () => _updateConstants(projectRoot, config));
  await _updateWithErrorHandling('Dart defines files', () => _writeDartDefines(projectRoot, config));
  await _updateWithErrorHandling('Bitbucket pipelines', () => _updateBitbucketPipelines(projectRoot, config));
  await _updateWithErrorHandling('Codemagic YAML', () => _updateCodemagicYaml(projectRoot, config));
  await _updateWithErrorHandling('Jenkinsfile', () => _updateJenkinsfile(projectRoot, config));
  await _updateWithErrorHandling('GitHub workflows', () => _updateGithubWorkflows(projectRoot, config));

  // Read current project state back and update README.input.md JSON
  final backfill = await _readProjectState(projectRoot, config);
  final merged = _deepMerge(config, backfill);
  await _writeInputJson(projectRoot, merged);

  if (exitCode == 0) {
    print('✅ Project updated successfully.');
  } else {
    print('❌ Some updates failed. Please check the errors above.');
  }
}

Future<void> _updateReadme(String root, Map<String, dynamic> config) async {
  final readmeFile = File(pathOf(root, 'README.md'));
  var readme = await readmeFile.readAsString();

  final projectName = (config['projectName'] ?? '').toString();
  final description = (config['description'] ?? '').toString();
  final flutterSdk = _extractFlutterSdkVersion(config);
  final cocoapodsVersion = _extractCocoapodsVersion(config);

  if (projectName.isNotEmpty) {
    readme = readme.replaceFirst(RegExp(r'^#\s+.*', multiLine: true), '# $projectName');
  }

  if (description.isNotEmpty) {
    final lines = readme.split('\n');
    if (lines.isNotEmpty) {
      final h1Index = lines.indexWhere((l) => l.trimLeft().startsWith('# '));
      if (h1Index != -1) {
        for (int i = h1Index + 1; i < lines.length; i++) {
          final trimmed = lines[i].trim();
          if (trimmed.isEmpty) continue;
          if (trimmed.startsWith('#')) continue;
          lines[i] = description;
          readme = lines.join('\n');
          break;
        }
      }
    }
  }

  if (flutterSdk != null && flutterSdk.isNotEmpty) {
    readme = _replaceBulletValue(
      readme,
      keyPattern: RegExp(r'^-\s+Flutter SDK:\s*.*$', multiLine: true),
      replacement: '- Flutter SDK: $flutterSdk',
    );
  }

  if (cocoapodsVersion != null && cocoapodsVersion.isNotEmpty) {
    readme = _replaceBulletValue(
      readme,
      keyPattern: RegExp(r'^-\s+CocoaPods:\s*.*$', multiLine: true),
      replacement: '- CocoaPods: $cocoapodsVersion',
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

  final android = (config['android'] as Map<String, dynamic>?);
  final applicationIds = android?['applicationIds'] as Map<String, dynamic>?;
  if (android != null) {
    final versionName = (android['versionName'] ?? '').toString();
    final versionCode = (android['versionCode'] ?? '').toString();

    // Update namespace with first applicationId (usually production)
    if (applicationIds != null && applicationIds.isNotEmpty) {
      final firstAppId = applicationIds.values.first.toString();
      if (firstAppId.isNotEmpty) {
      content = content.replaceAllMapped(
          RegExp(r'^(\s*)namespace\s*=\s*"[^"]+"', multiLine: true),
            (m) => '${m.group(1)}namespace = "$firstAppId"');
      }
    }
    if (versionName.isNotEmpty) {
      content = content.replaceAllMapped(
          RegExp(r'^(\s*)versionName\s*=\s*.*$', multiLine: true),
          (m) => '${m.group(1)}versionName = "$versionName"');
      content = content.replaceAllMapped(
          RegExp(r'^(\s*)versionName\s+"[^"]+"', multiLine: true),
          (m) => '${m.group(1)}versionName "$versionName"');
    }
    if (versionCode.isNotEmpty) {
      content = content.replaceAllMapped(
          RegExp(r'^(\s*)versionCode\s*=\s*.*$', multiLine: true),
          (m) => '${m.group(1)}versionCode = $versionCode');
      content = content.replaceAllMapped(
          RegExp(r'^(\s*)versionCode\s+\d+', multiLine: true),
          (m) => '${m.group(1)}versionCode $versionCode');
    }
  }

  // Update applicationIds and app names for each flavor
  final appNames = android != null ? (android['appNames'] as Map<String, dynamic>?) : null;
  if (applicationIds != null || appNames != null) {
    final flavors = applicationIds?.keys.toSet() ?? <String>{};
    if (appNames != null) {
      flavors.addAll(appNames.keys);
    }
    
    for (final flavor in flavors) {
      final appId = applicationIds?[flavor]?.toString() ?? '';
      final appName = appNames?[flavor]?.toString() ?? '';
      
      if (appId.isNotEmpty || appName.isNotEmpty) {
        // Update both applicationId and manifestPlaceholders["applicationName"] for specific flavor
        final flavorPattern = RegExp('$flavor\\s*\\{[\\s\\S]*?\\}');
        content = content.replaceAllMapped(flavorPattern, (match) {
          var flavorContent = match.group(0)!;
          
          if (appId.isNotEmpty) {
            flavorContent = flavorContent.replaceAllMapped(
                RegExp(r'applicationId\s+"[^"]+"'),
                (m) => 'applicationId "$appId"');
          }
          
          if (appName.isNotEmpty) {
            flavorContent = flavorContent.replaceAll(
        RegExp(r'manifestPlaceholders\["applicationName"\]\s*=\s*"[^"]+"'),
                'manifestPlaceholders["applicationName"] = "$appName"');
          }
          
          return flavorContent;
        });
      }
    }
  }

  await androidFile.writeAsString(content);
}

Future<void> _updateIosXcconfig(String root, Map<String, dynamic> config) async {
  final ios = (config['ios'] as Map<String, dynamic>?);
  if (ios == null) {
    throw Exception('iOS configuration not found in config');
  }
  
  final bundleIds = ios['bundleIds'] as Map<String, dynamic>?;
  final displayNames = ios['displayNames'] as Map<String, dynamic>?;
  
  if (bundleIds == null && displayNames == null) return;

  for (final f in _iosFlavors) {
    final file = File(pathOf(root, 'ios/Flutter/$f.xcconfig'));
    if (!await file.exists()) continue;
    var c = await file.readAsString();
    
    // Map flavor names to config keys
    final flavorKey = f.toLowerCase();
    final bundleId = bundleIds?[flavorKey]?.toString() ?? '';
    final displayName = displayNames?[flavorKey]?.toString() ?? '';
    
    if (bundleId.isNotEmpty) {
      c = c.replaceFirst(RegExp(r'^PRODUCT_BUNDLE_IDENTIFIER=.*', multiLine: true),
          'PRODUCT_BUNDLE_IDENTIFIER=$bundleId');
    }
    if (displayName.isNotEmpty) {
      c = c.replaceFirst(RegExp(r'^APP_DISPLAY_NAME=.*', multiLine: true),
          'APP_DISPLAY_NAME=$displayName');
    }
    await file.writeAsString(c);
  }
}

// Helper functions for constants parsing
String _formatDurationValue(String key, dynamic value) {
  final numVal = value is num ? value.toInt() : int.tryParse(value.toString()) ?? 0;
  final lower = key.toLowerCase();
  
  if (lower.endsWith('duration')) {
    return 'Duration(milliseconds: $numVal)';
  }
  if (lower.contains('timeout') || lower.contains('interval')) {
    return 'Duration(seconds: $numVal)';
  }
  
  return numVal.toString();
}

String _formatOrientationList(dynamic value) {
  if (value is! List) return "[\n  ]";
  final orientations = <String>{};
  for (final v in value) {
    final s = v.toString().toLowerCase();
    if (s == 'portrait' || s == 'portraitup') orientations.add('DeviceOrientation.portraitUp');
    if (s == 'portrait_down' || s == 'portraitdown') orientations.add('DeviceOrientation.portraitDown');
    if (s == 'landscape' || s == 'landscapeleft' || s == 'landscaperight') {
      orientations.add('DeviceOrientation.landscapeLeft');
      orientations.add('DeviceOrientation.landscapeRight');
    }
  }
  final items = orientations.toList();
  items.sort();
  final buffer = StringBuffer();
  buffer.writeln('[');
  for (final it in items) {
    buffer.writeln('    $it,');
  }
  buffer.write('  ]');
  return buffer.toString();
}

String _formatSystemUiOverlay(dynamic value) {
  if (value == null) return 'SystemUiOverlayStyle.dark';
  
  final str = value.toString().trim();
  
  // If it's already a SystemUiOverlayStyle, format it nicely
  if (str.startsWith('SystemUiOverlayStyle(')) {
    return _formatExistingSystemUiOverlay(str);
  }
  
  // Handle simple mode strings
  final mode = str.toLowerCase();
  final brightness = (mode == 'dark') ? 'Brightness.dark' : 'Brightness.light';
  
  return 'SystemUiOverlayStyle(\n'
      '    statusBarColor: Colors.transparent,\n'
      '    statusBarBrightness: $brightness,\n'
      '    statusBarIconBrightness: $brightness,\n'
      '    systemNavigationBarColor: Colors.transparent,\n'
      '    systemNavigationBarIconBrightness: $brightness,\n'
      '  )';
}

String _formatExistingSystemUiOverlay(String str) {
  // Extract the content inside SystemUiOverlayStyle(...)
  final match = RegExp(r'SystemUiOverlayStyle\(([^)]+)\)').firstMatch(str);
  if (match == null) return str;
  
  final content = match.group(1)!.trim();
  final properties = <String>[];
  
  // Parse properties
  final propPattern = RegExp(r'(\w+):\s*([^,]+)');
  final matches = propPattern.allMatches(content);
  
  for (final match in matches) {
    final key = match.group(1)!;
    final value = match.group(2)!.trim();
    properties.add('    $key: $value,');
  }
  
  if (properties.isEmpty) return str;
  
  return 'SystemUiOverlayStyle(\n${properties.join('\n')}\n  )';
}

String? _formatColorValue(String key, dynamic value) {
  if (value == null) return null;
  final raw = value.toString().trim();
  final hexNoPrefix = raw.replaceAll('#', '').toUpperCase().replaceAll(RegExp(r'^0X'), '');
  if (RegExp(r'^[0-9A-F]{6}$').hasMatch(hexNoPrefix)) {
    return 'Color(0xFF$hexNoPrefix)';
  }
  if (RegExp(r'^[0-9A-F]{8}$').hasMatch(hexNoPrefix)) {
    return 'Color(0x$hexNoPrefix)';
  }
  if (raw.startsWith('Color(')) return raw;
  if (raw.toLowerCase() == 'transparent') return 'Colors.transparent';
  return null;
}

String _formatDecoderType(dynamic value) {
  final str = value.toString().trim();
  
  // If already properly formatted, return as is
  if (str.contains('ErrorResponseDecoderType.') || str.contains('SuccessResponseDecoderType.')) {
    return str;
  }
  
  // If contains the enum name but missing the dot, add it
  if (str.contains('ErrorResponseDecoderType') && !str.contains('.')) {
    return 'ErrorResponseDecoderType.${str.replaceAll('ErrorResponseDecoderType', '').toLowerCase()}';
  }
  
  if (str.contains('SuccessResponseDecoderType') && !str.contains('.')) {
    return 'SuccessResponseDecoderType.${str.replaceAll('SuccessResponseDecoderType', '').toLowerCase()}';
  }
  
  // If it's just the enum value, determine the type from context
  final lowerStr = str.toLowerCase();
  if (lowerStr.contains('error') || lowerStr.contains('jsonobject') || lowerStr.contains('json')) {
    return 'ErrorResponseDecoderType.$lowerStr';
  } else if (lowerStr.contains('success') || lowerStr.contains('data') || lowerStr.contains('object')) {
    return 'SuccessResponseDecoderType.$lowerStr';
  }
  
  // Default fallback
  return 'ErrorResponseDecoderType.$lowerStr';
}

bool isColorConstant(String key, String formattedValue) {
  // Skip systemUiOverlay - it doesn't need ignore comments
  if (key.toLowerCase() == 'systemuioverlay') {
    return false;
  }
  
  final keyLower = key.toLowerCase();
  
  // Check if the key suggests it's a color
  final isColorKey = keyLower.contains('color') || 
                     keyLower.contains('theme') || 
                     keyLower.contains('background') || 
                     keyLower.contains('foreground');
  
  // Check if the formatted value is a Color
  final isColorValue = formattedValue.contains('Color(0x') || 
                       formattedValue.startsWith('Colors.');
  
  return isColorKey || isColorValue;
}

String _addIgnoreCommentsForColors(String content) {
  // Find all color constants that need ignore comments
  final colorPattern = RegExp(r'^(\s*)static const (\w+) = (Color\(0x[A-Fa-f0-9]+\)|Colors\.[a-zA-Z]+);', multiLine: true);
  
  return content.replaceAllMapped(colorPattern, (match) {
    final indent = match.group(1) ?? '  ';
    final constantName = match.group(2) ?? '';
    final colorValue = match.group(3) ?? '';
    
    // Check if ignore comment already exists for this specific constant
    final beforeMatch = content.substring(0, match.start);
    final lines = beforeMatch.split('\n');
    
    // Check last 10 lines for this specific constant's ignore comment
    final recentLines = lines.length > 10 ? lines.sublist(lines.length - 10) : lines;
    final hasIgnoreComment = recentLines.any((line) => 
      line.contains('// ignore: avoid_hard_coded_colors') && 
      (line.contains(constantName) || recentLines.indexOf(line) < recentLines.length - 2)
    );
    
    if (!hasIgnoreComment) {
      return '${indent}// ignore: avoid_hard_coded_colors\n${indent}static const $constantName = $colorValue;';
    }
    
    return match.group(0)!;
  });
}

String _formatConstantValue(String key, dynamic value) {
  final keyLower = key.toLowerCase();
  
  // Duration types
  if (keyLower.endsWith('duration') || keyLower.contains('timeout') || keyLower.contains('interval')) {
    return _formatDurationValue(key, value);
  }
  
  // Orientation types
  if (keyLower == 'mobileorientation' || keyLower == 'tabletorientation') {
    return _formatOrientationList(value);
  }
  
  // SystemUiOverlay
  if (keyLower == 'systemuioverlay') {
    return _formatSystemUiOverlay(value);
  }
  
  // Color types
  if (keyLower.endsWith('color') || keyLower.contains('color')) {
    final colorExpr = _formatColorValue(key, value);
    if (colorExpr != null) return colorExpr;
  }
  
  // Colors.* constants (like Colors.green, Colors.red, etc.)
  if (value.toString().startsWith('Colors.')) {
    return value.toString();
  }
  
  // Decoder types
  if (keyLower.contains('decodertype') || 
      keyLower.contains('decoder') ||
      keyLower.contains('errorresponsedecodertype') ||
      keyLower.contains('successresponsedecodertype') ||
      keyLower.contains('errorresponse') ||
      keyLower.contains('successresponse')) {
    return _formatDecoderType(value);
  }
  
  // List types
  if (value is List) {
    final listBody = value.map((e) => e is String ? "'${e.replaceAll("'", "\\'")}'" : e.toString()).join(', ');
    return '[$listBody]';
  }
  
  // String types
  if (value is String) {
    return "'${value.replaceAll("'", "\\'")}'";
  }
  
  // Bool types
  if (value is bool) {
    return value.toString();
  }
  
  // Number types
  if (value is num) {
    return value.toString();
  }
  
  return value.toString();
}


String _upsertConstantWithSection(String content, String key, dynamic value, String? section) {
  final fieldValue = _formatConstantValue(key, value);
  
  // Check if field exists - only replace the value part, preserve everything else
  final fieldPattern = RegExp('^(\\s*)static const $key\\s*=\\s*([^;]+);', multiLine: true);
  if (fieldPattern.hasMatch(content)) {
    // Replace only the value part, preserve ALL formatting including newlines
    return content.replaceAllMapped(fieldPattern, (match) {
      final fullMatch = match.group(0)!;
      final indent = match.group(1) ?? '  ';
      
      // Check if this is a color constant and add ignore comment if needed
      if (isColorConstant(key, fieldValue)) {
        // Check if ignore comment already exists nearby
        final ignorePattern = RegExp(r'//\s*ignore:\s*avoid_hard_coded_colors', multiLine: true);
        final beforeMatch = content.substring(0, match.start);
        final lastLines = beforeMatch.length >= 200 
            ? beforeMatch.substring(beforeMatch.length - 200)
            : beforeMatch;
        
        if (!ignorePattern.hasMatch(lastLines)) {
          // Add ignore comment before the constant
          final afterSemicolon = fullMatch.substring(fullMatch.indexOf(';') + 1);
          return '${indent}// ignore: avoid_hard_coded_colors\n${indent}static const $key = $fieldValue;$afterSemicolon';
        }
      }
      
      // Find the original line boundary and preserve everything after the semicolon
      final afterSemicolon = fullMatch.substring(fullMatch.indexOf(';') + 1);
      return '${indent}static const $key = $fieldValue;$afterSemicolon';
    });
  }
  
  // Determine target section based on constant type
  String? targetSection;
  final keyLower = key.toLowerCase();
  
  if (keyLower.contains('timeout') || keyLower.contains('interval') || keyLower.contains('retry')) {
    targetSection = 'API config';
  } else if (keyLower.contains('errorid')) {
    targetSection = 'error id';
  } else if (keyLower.contains('errorcode') || (keyLower.contains('error') && keyLower.contains('code'))) {
    targetSection = 'error code';
  } else if (keyLower.contains('error')) {
    targetSection = 'error field';
  } else if (keyLower.contains('duration') || keyLower.contains('transition')) {
    targetSection = 'Duration';
  } else if (keyLower.contains('width') || keyLower.contains('height') || keyLower.contains('device')) {
    targetSection = 'Design';
  } else if (keyLower.contains('page') || keyLower.contains('item')) {
    targetSection = 'Paging';
  } else if (keyLower.contains('format') || keyLower.contains('date')) {
    targetSection = 'Format';
  } else if (section != null) {
    // Use provided section
    switch (section.toLowerCase()) {
      case 'design':
        targetSection = 'Design';
        break;
      case 'paging':
        targetSection = 'Paging';
        break;
      case 'shimmer':
        targetSection = 'Shimmer';
        break;
      case 'formats':
        targetSection = 'Format';
        break;
      case 'durations':
        targetSection = 'Duration';
        break;
      case 'api':
        targetSection = 'API config';
        break;
    }
  }
  
  // Try to find existing section and insert after it
  if (targetSection != null) {
    final sectionPattern = RegExp('^\\s*//\\s*$targetSection\\b.*\$', multiLine: true);
    final sectionMatch = sectionPattern.firstMatch(content);
    if (sectionMatch != null) {
      final afterSectionIndex = sectionMatch.end;
      final rest = content.substring(afterSectionIndex);
      
      // Find the next section (any comment starting with // ) or end of class
      final nextSectionPattern = RegExp('^\\s*//\\s+.+', multiLine: true);
      final nextSectionMatch = nextSectionPattern.firstMatch(rest);
      final insertPos = nextSectionMatch != null 
          ? afterSectionIndex + nextSectionMatch.start
          : content.lastIndexOf('}'); // Before closing brace
      
      final before = content.substring(0, insertPos);
      final after = content.substring(insertPos);
      
      // Ensure proper newlines and indentation
      final needsLeadingNewline = !before.endsWith('\n') && before.isNotEmpty;
      final needsTrailingNewline = !after.startsWith('\n') && after.isNotEmpty;
      
      // Check if this is a color constant and add ignore comment if needed
      String newField;
      if (isColorConstant(key, fieldValue)) {
        // Check if ignore comment already exists nearby
        final ignorePattern = RegExp(r'//\s*ignore:\s*avoid_hard_coded_colors', multiLine: true);
        final lastLines = before.length >= 200 
            ? before.substring(before.length - 200)
            : before;
        
        if (!ignorePattern.hasMatch(lastLines)) {
          newField = '${needsLeadingNewline ? '\n' : ''}    // ignore: avoid_hard_coded_colors\n  static const $key = $fieldValue;${needsTrailingNewline ? '\n' : ''}';
        } else {
          newField = '${needsLeadingNewline ? '\n' : ''}  static const $key = $fieldValue;${needsTrailingNewline ? '\n' : ''}';
        }
      } else {
        newField = '${needsLeadingNewline ? '\n' : ''}  static const $key = $fieldValue;${needsTrailingNewline ? '\n' : ''}';
      }
      return before + newField + after;
    }
  }
  
  // Fallback: Insert at the end of class, before closing brace
  final classEndPattern = RegExp(r'^(\s*)\}\s*$', multiLine: true);
  final match = classEndPattern.firstMatch(content);
  if (match != null) {
    // Always use 2 spaces indentation for constants
    // Check if this is a color constant and add ignore comment if needed
    String newField;
    if (isColorConstant(key, fieldValue)) {
      // Check if ignore comment already exists nearby
      final ignorePattern = RegExp(r'//\s*ignore:\s*avoid_hard_coded_colors', multiLine: true);
      final lastLines = content.length >= 200 
          ? content.substring(content.length - 200)
          : content;
      
      if (!ignorePattern.hasMatch(lastLines)) {
        newField = '  // ignore: avoid_hard_coded_colors\n  static const $key = $fieldValue;\n';
      } else {
        newField = '  static const $key = $fieldValue;\n';
      }
    } else {
      newField = '  static const $key = $fieldValue;\n';
    }
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
  final constants = (config['constants'] as Map<String, dynamic>?);
  if (constants == null) return;

  // Process constants in order based on JSON structure
  void processConstants(Map<String, dynamic> node, String? section) {
    node.forEach((k, v) {
      if (v is Map<String, dynamic>) {
        // Process nested objects (like design, paging, etc.)
        processConstants(v, k);
      } else {
        // Process individual constants
        content = _upsertConstantWithSection(content, k, v, section);
      }
    });
  }

  processConstants(constants, null);
  
  // Add ignore comments for all hardcoded colors
  content = _addIgnoreCommentsForColors(content);
  
  await constFile.writeAsString(content);
}

Future<void> _writeDartDefines(String root, Map<String, dynamic> config) async {
  // Auto-detect flavors from various config sources
  final flavors = _detectFlavorsFromConfig(config);
  final envKeys = (config['envKeys'] as Map<String, dynamic>?);

  final dir = Directory(pathOf(root, 'dart_defines'));
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  for (final flavor in flavors) {
    final map = <String, dynamic>{
      'FLAVOR': flavor,
    };
    if (envKeys != null) {
      // Check if envKeys is structured by flavor
      if (envKeys.containsKey(flavor) && envKeys[flavor] is Map) {
        // New structure: envKeys[flavor] = {key: value}
        final flavorEnvKeys = envKeys[flavor] as Map<String, dynamic>;
        for (final entry in flavorEnvKeys.entries) {
          map[entry.key] = entry.value;
        }
      } else {
        // Old structure: envKeys = {key: value} (backward compatibility)
      for (final entry in envKeys.entries) {
          if (entry.value is! Map) { // Skip flavor-specific entries
        map[entry.key] = entry.value;
          }
        }
      }
    }
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

  final lefthook = (config['lefthook'] as Map<String, dynamic>?);
  final projectCode = lefthook != null ? (lefthook['projectCode'] ?? '').toString() : '';
  if (projectCode.isNotEmpty) {
    c = _updateProjectCodeInContent(c, projectCode);
  }

  await file.writeAsString(c);
}

Future<void> _updateCodemagicYaml(String root, Map<String, dynamic> config) async {
  final file = File(pathOf(root, 'codemagic.yaml'));
  if (!await file.exists()) return;

  final flutterSdk = _extractFlutterSdkVersion(config);
  final cocoapods = _extractCocoapodsVersion(config);

  var updated = false;
  if (flutterSdk != null && flutterSdk.isNotEmpty) {
    updated = await _updateVersionInFile(
      file.path,
          RegExp(r'^(\s*)flutter:\s*(\d+\.\d+\.\d+)', multiLine: true),
      flutterSdk,
      '{indent}flutter: {version}',
    ) || updated;
  }
  if (cocoapods != null && cocoapods.isNotEmpty) {
    updated = await _updateVersionInFile(
      file.path,
          RegExp(r'^(\s*)cocoapods:\s*(\d+\.\d+\.\d+)', multiLine: true),
      cocoapods,
      '{indent}cocoapods: {version}',
    ) || updated;
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
          RegExp(r"ghcr\.io/cirruslabs/flutter:\d+\.\d+\.\d+"),
          '$_flutterImagePrefix$flutterSdk');
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

String? _extractJsonBlock(String content) {
  final regex = RegExp(r'```json\s*([\s\S]*?)\s*```', multiLine: true);
  final match = regex.firstMatch(content);
  if (match == null) return null;
  
  var jsonContent = match.group(1)!;
  
  // Fix systemUiOverlay multiline strings
  jsonContent = _fixMultilineStrings(jsonContent);
  
  return jsonContent;
}

String _fixMultilineStrings(String content) {
  // Fix systemUiOverlay multiline SystemUiOverlayStyle
  final systemUiPattern = RegExp(r'"systemUiOverlay":\s*"SystemUiOverlayStyle\(\s*([\s\S]*?)\s*\)"', multiLine: true);
  
  return content.replaceAllMapped(systemUiPattern, (match) {
    final innerContent = match.group(1)!.trim();
    // Remove newlines and extra spaces, keep single spaces
    final cleaned = innerContent.replaceAll(RegExp(r'\s+'), ' ');
    return '"systemUiOverlay": "SystemUiOverlayStyle($cleaned)"';
  });
}

String pathOf(String root, String relative) =>
    root.endsWith('/') ? (root + relative) : (root + '/' + relative);

String _replaceBulletValue(String input, {required RegExp keyPattern, required String replacement}) {
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

Future<Map<String, dynamic>> _readProjectState(String root, Map<String, dynamic>? config) async {
  final result = <String, dynamic>{};

  // Flutter/CocoaPods from workflows & codemagic
  final flutterVer = await _readFlutterVersionFromWorkflows(root) ?? await _readFlutterVersionFromCodemagic(root);
  final cocoapodsVer = await _readCocoapodsFromCodemagic(root);
  if (flutterVer != null) {
    result['flutter'] = {'sdkVersion': flutterVer};
  }
  if (cocoapodsVer != null) {
    result['cocoapods'] = {'version': cocoapodsVer};
  }

  // Android build.gradle
  final android = await _readAndroidGradle(root);
  if (android.isNotEmpty) result['android'] = android;

  // iOS xcconfig
  final ios = await _readIosXcconfig(root);
  if (ios.isNotEmpty) result['ios'] = ios;


  // Auto-detect flavors from config sources
  final detectedFlavors = config != null ? _detectFlavorsFromConfig(config) : _defaultFlavors;
  result['flavors'] = detectedFlavors;

  // envKeys from dart_defines files if exists
  final envKeys = await _readEnvKeys(root, detectedFlavors);
  if (envKeys.isNotEmpty) result['envKeys'] = envKeys;

  // lefthook projectCode from bitbucket rules if found
  final code = await _readProjectCodeFromPipelines(root);
  if (code != null) result['lefthook'] = {'projectCode': code};

  return result;
}

Future<void> _writeInputJson(String root, Map<String, dynamic> data) async {
  final inputFile = File(pathOf(root, 'README.input.md'));
  if (!await inputFile.exists()) return;
  final content = await inputFile.readAsString();
  final jsonRaw = const JsonEncoder.withIndent('  ').convert(data);
  final newBlock = '```json\n$jsonRaw\n```';
  final newContent = content.replaceFirst(RegExp(r'```json[\s\S]*?```', multiLine: true), newBlock);
  await inputFile.writeAsString(newContent);
}

Map<String, dynamic> _deepMerge(Map<String, dynamic> base, Map<String, dynamic> next) {
  final out = <String, dynamic>{}..addAll(base);
  next.forEach((k, v) {
    if (v is Map && base[k] is Map) {
      out[k] = _deepMerge(base[k] as Map<String, dynamic>, v as Map<String, dynamic>);
    } else {
      out[k] = v;
    }
  });
  return out;
}


Future<Map<String, dynamic>> _readAndroidGradle(String root) async {
  final file = File(pathOf(root, 'android/app/build.gradle'));
  if (!await file.exists()) return {};
  final c = await file.readAsString();
  final appId = RegExp(r'^\s*applicationId\s+"([^"]+)"', multiLine: true).firstMatch(c)?.group(1);
  final namespace = RegExp(r'^\s*namespace\s*=\s*"([^"]+)"', multiLine: true).firstMatch(c)?.group(1);
  final versionName = RegExp(r'^\s*versionName\s*(=\s*|)"([^"]+)"', multiLine: true).firstMatch(c)?.group(2);
  final versionCode = RegExp(r'^\s*versionCode\s*(=\s*|)(\d+)', multiLine: true).firstMatch(c)?.group(2);
  final flavors = RegExp(r'productFlavors\s*\{([\s\S]*?)\}', multiLine: true).firstMatch(c)?.group(1);
  final flavorNames = <String>[];
  if (flavors != null) {
    final it = RegExp(r'^(\s*)([a-zA-Z0-9_]+)\s*\{', multiLine: true).allMatches(flavors);
    for (final m in it) {
      final name = m.group(2)!;
      if (!['dimension'].contains(name)) flavorNames.add(name);
    }
  }
  // Read applicationIds and app names for each flavor
  final applicationIds = <String, String>{};
  final appNames = <String, String>{};
  if (flavors != null) {
    for (final flavorName in flavorNames) {
      final flavorPattern = RegExp('$flavorName\\s*\\{[\\s\\S]*?\\}');
      final match = flavorPattern.firstMatch(c);
      if (match != null) {
        final flavorContent = match.group(0)!;
        
        // Extract applicationId
        final appIdMatch = RegExp(r'applicationId\s+"([^"]+)"').firstMatch(flavorContent);
        if (appIdMatch != null) {
          applicationIds[flavorName] = appIdMatch.group(1)!;
        }
        
        // Extract app name
        final appNameMatch = RegExp(r'manifestPlaceholders\["applicationName"\]\s*=\s*"([^"]+)"').firstMatch(flavorContent);
        if (appNameMatch != null) {
          appNames[flavorName] = appNameMatch.group(1)!;
        }
      }
    }
  }

  final map = <String, dynamic>{};
  if (appId != null) map['applicationId'] = appId;
  if (namespace != null) map['namespace'] = namespace;
  if (versionName != null) map['versionName'] = versionName;
  if (versionCode != null) map['versionCode'] = int.tryParse(versionCode) ?? versionCode;
  if (flavorNames.isNotEmpty) map['flavors'] = flavorNames;
  if (applicationIds.isNotEmpty) map['applicationIds'] = applicationIds;
  if (appNames.isNotEmpty) map['appNames'] = appNames;
  return map;
}

Future<Map<String, dynamic>> _readIosXcconfig(String root) async {
  final bundleIds = <String, String>{};
  final displayNames = <String, String>{};
  
  for (final f in _iosFlavors) {
    final file = File(pathOf(root, 'ios/Flutter/$f.xcconfig'));
    if (!await file.exists()) continue;
    final c = await file.readAsString();
    
    final flavorKey = f.toLowerCase();
    final bundleId = RegExp(r'^PRODUCT_BUNDLE_IDENTIFIER=(.*)$', multiLine: true).firstMatch(c)?.group(1)?.trim();
    final displayName = RegExp(r'^APP_DISPLAY_NAME=(.*)$', multiLine: true).firstMatch(c)?.group(1)?.trim();
    
    if (bundleId != null) bundleIds[flavorKey] = bundleId;
    if (displayName != null) displayNames[flavorKey] = displayName;
  }
  
  final map = <String, dynamic>{};
  if (bundleIds.isNotEmpty) map['bundleIds'] = bundleIds;
  if (displayNames.isNotEmpty) map['displayNames'] = displayNames;
  return map;
}



Future<Map<String, dynamic>> _readEnvKeys(String root, List<String>? configFlavors) async {
  final flavors = configFlavors ?? _defaultFlavors;
  final envKeysByFlavor = <String, Map<String, dynamic>>{};
  
  for (final flavor in flavors) {
    final file = File(pathOf(root, 'dart_defines/$flavor.json'));
    if (!await file.exists()) continue;
  final c = await file.readAsString();
    if (c.trim().isEmpty) continue; // Skip empty files
    try {
  final map = json.decode(c) as Map<String, dynamic>;
  map.remove('FLAVOR');
      if (map.isNotEmpty) {
        envKeysByFlavor[flavor] = map;
      }
    } catch (e) {
      // Skip files with invalid JSON
      continue;
    }
  }
  
  // If all flavors have the same envKeys, return the old structure for backward compatibility
  if (envKeysByFlavor.length == 1) {
    return envKeysByFlavor.values.first;
  }
  
  // If flavors have different envKeys, return the new structure
  if (envKeysByFlavor.isNotEmpty) {
    return envKeysByFlavor;
  }
  
  return {};
}

Future<String?> _readProjectCodeFromPipelines(String root) async {
  final file = File(pathOf(root, 'bitbucket-pipelines.yml'));
  if (!await file.exists()) return null;
  final c = await file.readAsString();
  final m = RegExp(r"'(feature|bugfix|hotfix|release)/([A-Z0-9]+)-\*'", multiLine: true).firstMatch(c);
  return m?.group(2);
}
