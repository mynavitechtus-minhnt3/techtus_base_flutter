import 'dart:convert';
import 'dart:io';

/// Tool to generate API methods from OpenAPI JSON specification
///
/// Usage: dart tools/dart_tools/lib/generate_api_from_openapi.dart [--input_path=path] [--apis=method_path,method_path] [--replace=true/false] [--output_path=path]

/// - input_path: path to the folder containing the OpenAPI JSON file
/// - apis: filter specific APIs by method and path (e.g., apis=get_v1/search,post_v2/city)
/// - replace: true to replace all code below marker, false to append (default: true)
/// - output_path: custom output directory (default: lib/data_source/api and lib/model/api)
void main(List<String> args) {
  if (args.isEmpty) {
    print('❌ Error: Please provide folder path containing OpenAPI JSON file');
    print(
        'Usage: dart tools/dart_tools/lib/generate_api_from_openapi.dart [--input_path=path] [--apis=method_path,method_path] [--replace=true/false] [--output_path=path]');
    print('Examples:');
    print('  dart tools/dart_tools/lib/generate_api_from_openapi.dart --input_path=api_doc');
    print(
        '  dart tools/dart_tools/lib/generate_api_from_openapi.dart --input_path=api_doc --apis=get_v1/search,post_v2/city');
    print(
        '  dart tools/dart_tools/lib/generate_api_from_openapi.dart --input_path=api_doc --replace=false');
    print(
        '  dart tools/dart_tools/lib/generate_api_from_openapi.dart --input_path=api_doc --output_path=api_doc');
    exit(1);
  }

  // Parse additional arguments
  String? apisFilter;
  bool replace = true;
  String? outputPath;
  String? inputPath;

  for (int i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg.startsWith('--apis=')) {
      apisFilter = arg.substring(7);
    } else if (arg.startsWith('--replace=')) {
      final replaceStr = arg.substring(10).toLowerCase();
      replace = replaceStr == 'true';
    } else if (arg.startsWith('--output_path=')) {
      outputPath = arg.substring(14);
    } else if (arg.startsWith('--input_path=')) {
      inputPath = arg.substring(13);
    }
  }

  final generator = ApiGenerator();

  try {
    generator.generateFromFolder(
      inputPath!,
      apisFilter: apisFilter,
      replace: replace,
      outputPath: outputPath,
    );
    print('✅ Successfully generated API methods from OpenAPI!');
    print(
        '⚠️  WARNING: We only use _authAppServerApiClient for all APIs. For APIs that should use _noneAuthAppServerApiClient, you must manually modify them.');
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}

class ApiGenerator {
  static const String appApiServicePath = 'lib/data_source/api/app_api_service.dart';
  static const String modelApiPath = 'lib/model/api';
  static const String generatedMethodsMarker =
      '// GENERATED CODE - DO NOT MODIFY OR DELETE THIS COMMENT';

  late String _appApiServicePath;
  late String _modelApiPath;
  late bool _replace;
  late Set<String> _allowedApis;

  void generateFromFolder(
    String folderPath, {
    String? apisFilter,
    bool replace = true,
    String? outputPath,
  }) {
    // Initialize configuration
    _replace = replace;
    _allowedApis = _parseApisFilter(apisFilter);

    if (outputPath != null) {
      _appApiServicePath = '$outputPath/app_api_service.dart';
      _modelApiPath = '$outputPath/model';
    } else {
      _appApiServicePath = appApiServicePath;
      _modelApiPath = modelApiPath;
    }
    print('📁 Checking folder: $folderPath');
    if (_allowedApis.isNotEmpty) {
      print('🔍 Filtering APIs: ${_allowedApis.join(', ')}');
    }
    print('🔄 Replace mode: $_replace');
    print('📂 Output paths:');
    print('  - API Service: $_appApiServicePath');
    print('  - Models: $_modelApiPath');

    // Check if folder exists
    final folder = Directory(folderPath);
    if (!folder.existsSync()) {
      throw Exception('Folder does not exist: $folderPath');
    }

    // Find JSON files in folder
    final jsonFiles = folder
        .listSync()
        .whereType<File>()
        .where((file) => file.path.toLowerCase().endsWith('.json'))
        .toList();

    if (jsonFiles.isEmpty) {
      throw Exception('No JSON files found in folder: $folderPath');
    }

    if (jsonFiles.length > 1) {
      print('⚠️ Multiple JSON files found, using: ${jsonFiles.first.path}');
    }

    final openApiFilePath = jsonFiles.first.path;
    generateFromOpenApi(openApiFilePath);
  }

  Set<String> _parseApisFilter(String? apisFilter) {
    if (apisFilter == null || apisFilter.isEmpty) {
      return <String>{};
    }

    return apisFilter.split(',').map((api) => api.trim().toLowerCase()).toSet();
  }

  bool _shouldIncludeEndpoint(EndpointInfo endpoint) {
    if (_allowedApis.isEmpty) return true;

    // Create key in format: method_path (e.g., "get_v1/search", "post_v2/city")
    final key = '${endpoint.method.toLowerCase()}_${endpoint.path}'.toLowerCase();
    return _allowedApis.contains(key);
  }

  void generateFromOpenApi(String openApiFilePath) {
    print('📖 Reading OpenAPI file: $openApiFilePath');

    // Read OpenAPI JSON file
    final openApiFile = File(openApiFilePath);
    if (!openApiFile.existsSync()) {
      throw Exception('OpenAPI file does not exist: $openApiFilePath');
    }

    final openApiContent = openApiFile.readAsStringSync();
    final openApiData = jsonDecode(openApiContent) as Map<String, dynamic>;

    print('🔍 Analyzing endpoints...');

    // Analyze endpoints
    final endpoints = _analyzeEndpoints(openApiData);
    print('📊 Found ${endpoints.length} endpoints');

    // Generate API methods
    print('🛠️ Generating API methods...');
    final apiMethods = _generateApiMethods(endpoints);

    // Generate model classes
    print('🏗️ Generating model classes...');
    final generatedModels = _generateModelClasses(endpoints);

    // Update app_api_service.dart file
    print('📝 Updating app_api_service.dart...');
    _updateAppApiService(apiMethods);

    print(
        '✨ Generated ${apiMethods.length} API methods and ${generatedModels.length} model classes');
  }

  List<EndpointInfo> _analyzeEndpoints(Map<String, dynamic> openApiData) {
    final endpoints = <EndpointInfo>[];
    final paths = openApiData['paths'] as Map<String, dynamic>? ?? {};
    final components = openApiData['components'] as Map<String, dynamic>? ?? {};

    for (final pathEntry in paths.entries) {
      final path = pathEntry.key;
      final methods = pathEntry.value as Map<String, dynamic>;

      for (final methodEntry in methods.entries) {
        final method = methodEntry.key;
        final details = methodEntry.value as Map<String, dynamic>;

        final endpoint = EndpointInfo(
          method: method.toUpperCase(),
          path: path,
          queryParams: _extractQueryParams(details),
          hasBody: _hasRequestBody(details),
          bodyExample: _generateBodyExample(details, components),
          responseExample: _generateResponseExample(details, components),
        );

        endpoints.add(endpoint);
      }
    }

    return endpoints;
  }

  List<QueryParam> _extractQueryParams(Map<String, dynamic> details) {
    final parameters = details['parameters'] as List<dynamic>? ?? [];
    final queryParams = <QueryParam>[];

    for (final param in parameters) {
      final paramMap = param as Map<String, dynamic>;
      if (paramMap['in'] == 'query') {
        final schema = paramMap['schema'] as Map<String, dynamic>? ?? {};
        queryParams.add(QueryParam(
          name: paramMap['name'] as String,
          type: schema['type'] as String? ?? 'string',
          required: paramMap['required'] as bool? ?? false,
        ));
      }
    }

    return queryParams;
  }

  bool _hasRequestBody(Map<String, dynamic> details) {
    return details.containsKey('requestBody');
  }

  dynamic _generateBodyExample(Map<String, dynamic> details, Map<String, dynamic> components) {
    final requestBody = details['requestBody'] as Map<String, dynamic>?;
    if (requestBody == null) return null;

    final content = requestBody['content'] as Map<String, dynamic>? ?? {};
    final jsonContent = content['application/json'] as Map<String, dynamic>? ?? {};
    final schema = jsonContent['schema'] as Map<String, dynamic>? ?? {};

    return _generateExampleFromSchema(schema, components);
  }

  dynamic _generateResponseExample(Map<String, dynamic> details, Map<String, dynamic> components) {
    final responses = details['responses'] as Map<String, dynamic>? ?? {};
    final successResponse = responses['200'] ?? responses['201'] ?? responses['202'];

    if (successResponse == null) return null;

    final successMap = successResponse as Map<String, dynamic>;
    final content = successMap['content'] as Map<String, dynamic>? ?? {};
    final jsonContent = content['application/json'] as Map<String, dynamic>? ?? {};
    final schema = jsonContent['schema'] as Map<String, dynamic>? ?? {};

    return _generateExampleFromSchema(schema, components);
  }

  dynamic _generateExampleFromSchema(Map<String, dynamic> schema, Map<String, dynamic> components,
      [Set<String>? visited]) {
    visited ??= <String>{};

    if (schema.containsKey('\$ref')) {
      final ref = schema['\$ref'] as String;
      if (visited.contains(ref)) return null; // Prevent circular references

      visited.add(ref);
      final resolvedSchema = _resolveRef(ref, components);
      return _generateExampleFromSchema(resolvedSchema, components, visited);
    }

    final type = schema['type'] as String?;

    switch (type) {
      case 'object':
        final properties = schema['properties'] as Map<String, dynamic>? ?? {};
        final example = <String, dynamic>{};

        for (final prop in properties.entries) {
          final propSchema = prop.value as Map<String, dynamic>;
          example[prop.key] = _generateExampleFromSchema(propSchema, components, visited);
        }

        return example;

      case 'array':
        final items = schema['items'] as Map<String, dynamic>? ?? {};
        final itemExample = _generateExampleFromSchema(items, components, visited);
        return itemExample != null ? [itemExample] : [];

      case 'string':
        final enumValues = schema['enum'] as List<dynamic>?;
        if (enumValues != null && enumValues.isNotEmpty) {
          return enumValues.first as String;
        }
        return 'string_value';

      case 'integer':
        return 0;

      case 'number':
        return 0.0;

      case 'boolean':
        return false;

      default:
        return null;
    }
  }

  Map<String, dynamic> _resolveRef(String ref, Map<String, dynamic> components) {
    if (ref.startsWith('#/components/schemas/')) {
      final schemaName = ref.split('/').last;
      final schemas = components['schemas'] as Map<String, dynamic>? ?? {};
      return schemas[schemaName] as Map<String, dynamic>? ?? {};
    }
    return {};
  }

  List<String> _generateApiMethods(List<EndpointInfo> endpoints) {
    final methods = <String>[];

    // Build a set of all v1 paths for v2 comparison
    final v1Paths = endpoints.where((e) => !e.path.startsWith('/v2/')).map((e) => e.path).toSet();

    for (final endpoint in endpoints) {
      if (endpoint.responseExample == null) continue;
      if (!_shouldIncludeEndpoint(endpoint)) continue;

      final methodCode = _generateSingleApiMethod(endpoint, v1Paths);
      methods.add(methodCode);
    }

    return methods;
  }

  String _generateSingleApiMethod(EndpointInfo endpoint, Set<String> v1Paths) {
    final methodName = _generateMethodName(endpoint.path, endpoint.method, v1Paths);
    final modelName = _generateModelName(endpoint.path);
    // Always use _authAppServerApiClient for consistency
    final client = '_authAppServerApiClient';

    // Generate parameters
    final params = <String>[];
    final queryLines = <String>[];

    // Required params first
    final requiredParams = endpoint.queryParams.where((p) => p.required).toList();
    final optionalParams = endpoint.queryParams.where((p) => !p.required).toList();

    for (final param in requiredParams) {
      final dartType = param.type == 'integer' ? 'int' : 'String';
      params.add('required $dartType ${_toCamelCase(param.name)}');
    }

    for (final param in optionalParams) {
      final dartType = param.type == 'integer' ? 'int' : 'String';
      params.add('$dartType? ${_toCamelCase(param.name)}');
    }

    if (endpoint.hasBody) {
      params.add('required Map<String, dynamic> body');
    }

    // Generate query parameters
    if (endpoint.queryParams.isNotEmpty) {
      queryLines.add('      queryParameters: {');
      for (final param in endpoint.queryParams) {
        final camelName = _toCamelCase(param.name);
        if (param.required) {
          queryLines.add("        '${param.name}': $camelName,");
        } else {
          queryLines.add("        if ($camelName != null) '${param.name}': $camelName,");
        }
      }
      queryLines.add('      },');
    }

    // Generate method body
    final methodLines = <String>[];

    // Add method signature - only add {} if there are parameters
    if (params.isNotEmpty) {
      methodLines.addAll([
        '  Future<$modelName?> $methodName({',
        '    ${params.join(',\n    ')},',
        '  }) async {',
      ]);
    } else {
      methodLines.addAll([
        '  Future<$modelName?> $methodName() async {',
      ]);
    }

    methodLines.addAll([
      '    return $client.request(',
      '      method: RestMethod.${endpoint.method.toLowerCase()},',
      "      path: '${endpoint.path.startsWith('/') ? endpoint.path.substring(1) : endpoint.path}',",
    ]);

    if (queryLines.isNotEmpty) {
      methodLines.addAll(queryLines);
    }

    if (endpoint.hasBody) {
      methodLines.add('      body: body,');
    }

    methodLines.addAll([
      '      successResponseDecoderType: SuccessResponseDecoderType.jsonObject,',
      '      decoder: (json) => $modelName.fromJson(json.safeCast<Map<String, dynamic>>() ?? {}),',
      '    );',
      '  }',
    ]);

    return methodLines.join('\n');
  }

  String _generateMethodName(String path, String method, Set<String> v1Paths) {
    final cleanPath = _cleanPathForName(path);

    // Convert to proper camelCase method name
    String methodName;
    if (method == 'GET') {
      methodName = 'get${_toPascalCase(cleanPath)}';
    } else if (method == 'POST') {
      methodName = 'post${_toPascalCase(cleanPath)}';
    } else if (method == 'PUT') {
      methodName = 'put${_toPascalCase(cleanPath)}';
    } else if (method == 'PATCH') {
      methodName = 'patch${_toPascalCase(cleanPath)}';
    } else if (method == 'DELETE') {
      methodName = 'delete${_toPascalCase(cleanPath)}';
    } else {
      methodName = _toCamelCase(cleanPath);
    }

    // Handle v2 endpoints - add V2 suffix if needed
    if (path.startsWith('/v2/')) {
      // Check if there's a v1 equivalent
      final v1Path = path.replaceFirst('/v2/', '/');
      if (v1Paths.contains(v1Path)) {
        methodName += 'V2';
      }
    }

    return methodName;
  }

  String _generateModelName(String path) {
    final cleanPath = _cleanPathForName(path);
    final modelName = 'Api${_toPascalCase(cleanPath)}Data';

    return modelName;
  }

  String _cleanPathForName(String path) {
    var clean = path.replaceFirst('/', '').replaceAll('v2/', '');

    // Special handling for complex paths like 'getRecommendations/savedSearches'
    // Remove common prefixes that shouldn't be in method names
    clean = clean.replaceFirst('get', '');
    clean = clean.replaceFirst('post', '');
    clean = clean.replaceFirst('put', '');
    clean = clean.replaceFirst('patch', '');
    clean = clean.replaceFirst('delete', '');

    // Convert hyphens and slashes to underscores
    clean = clean.replaceAll(RegExp(r'[-/]'), '_');
    clean = clean.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    clean = clean.replaceAll(RegExp(r'_+'), '_');
    return clean.replaceAll(RegExp(r'^_|_$'), '');
  }

  void _updateAppApiService(List<String> apiMethods) {
    final file = File(_appApiServicePath);
    if (!file.existsSync()) {
      // Try to copy from the default location if using custom output path
      if (_appApiServicePath != appApiServicePath) {
        final sourceFile = File(appApiServicePath);
        if (sourceFile.existsSync()) {
          print('📋 Copying app_api_service.dart from ${sourceFile.path} to $_appApiServicePath');
          // Create directory if it doesn't exist
          file.parent.createSync(recursive: true);
          // Copy file content
          file.writeAsStringSync(sourceFile.readAsStringSync());
        } else {
          throw Exception('Source app_api_service.dart file does not exist: ${sourceFile.path}');
        }
      } else {
        throw Exception('app_api_service.dart file does not exist: $_appApiServicePath');
      }
    }

    var content = file.readAsStringSync();

    // Find marker position
    var markerIndex = content.indexOf(generatedMethodsMarker);

    // If marker doesn't exist, add it before the last closing brace
    if (markerIndex == -1) {
      print('🔧 Marker not found, adding it automatically...');
      final classEndIndex = content.lastIndexOf('}');
      if (classEndIndex == -1) {
        throw Exception('Could not find class end');
      }

      // Insert marker before the last closing brace
      final beforeClassEnd = content.substring(0, classEndIndex);
      final afterClassEnd = content.substring(classEndIndex);
      content = '$beforeClassEnd\n  $generatedMethodsMarker\n$afterClassEnd';
      markerIndex = content.indexOf(generatedMethodsMarker);
    }

    // Find class end position (last closing brace)
    final classEndIndex = content.lastIndexOf('}');
    if (classEndIndex == -1) {
      throw Exception('Could not find class end');
    }

    final newMethods = apiMethods.join('\n\n');
    String newContent;

    if (_replace) {
      // Replace mode: Remove all methods after marker
      final beforeMarker = content.substring(0, markerIndex + generatedMethodsMarker.length);
      final afterClass = content.substring(classEndIndex);
      newContent = '$beforeMarker\n\n$newMethods\n$afterClass';
    } else {
      // Append mode: Add new methods before class end
      final beforeClassEnd = content.substring(0, classEndIndex);
      final afterClassEnd = content.substring(classEndIndex);
      newContent = '$beforeClassEnd\n\n$newMethods\n$afterClassEnd';
    }

    // Write file
    file.writeAsStringSync(newContent);

    final mode = _replace ? 'replaced' : 'appended';
    print('📝 ${mode.toUpperCase()} ${apiMethods.length} API methods in $_appApiServicePath');
  }

  List<String> _generateModelClasses(List<EndpointInfo> endpoints) {
    final generatedModels = <String>[];
    final processedModels = <String>{};
    final allNestedClasses = <String, String>{}; // className -> classContent

    for (final endpoint in endpoints) {
      if (endpoint.responseExample == null) continue;
      if (!_shouldIncludeEndpoint(endpoint)) continue;

      final modelName = _generateModelName(endpoint.path);

      // Skip if already processed
      if (processedModels.contains(modelName)) continue;
      processedModels.add(modelName);

      // Generate model file with nested classes
      final result = _generateModelFileWithNested(modelName, endpoint.responseExample);
      final fileName = _modelNameToFileName(modelName);

      // Store nested classes
      allNestedClasses.addAll(result.nestedClasses);

      // Write model file
      _writeModelFile(fileName, result.mainContent);
      generatedModels.add(modelName);
    }

    // Write nested classes as separate files
    for (final entry in allNestedClasses.entries) {
      final nestedClassName = entry.key;
      final nestedContent = entry.value;
      final nestedFileName = _modelNameToFileName(nestedClassName);

      if (!processedModels.contains(nestedClassName)) {
        _writeModelFile(nestedFileName, nestedContent);
        generatedModels.add(nestedClassName);
        processedModels.add(nestedClassName);
      }
    }

    return generatedModels;
  }

  ModelGenerationResult _generateModelFileWithNested(String modelName, dynamic responseExample) {
    final fileName = _modelNameToFileName(modelName);
    final imports = _generateImports(fileName);
    final result = _generateModelClassWithNested(modelName, responseExample);

    final mainContent = '''$imports

${result.mainClass}''';

    return ModelGenerationResult(
      mainContent: mainContent,
      nestedClasses: result.nestedClasses,
    );
  }

  ModelClassResult _generateModelClassWithNested(String modelName, dynamic responseExample,
      [String? prefix]) {
    if (responseExample == null) {
      return ModelClassResult(mainClass: '', nestedClasses: {});
    }

    final className = prefix != null ? '$prefix$modelName' : modelName;
    final privateClassName = '_\$${className}';
    final factoryName = '_$className';
    final nestedClasses = <String, String>{};

    if (responseExample is Map<String, dynamic>) {
      final fieldsResult = _generateFieldsWithNested(responseExample, className);
      nestedClasses.addAll(fieldsResult.nestedClasses);

      final mainClass = '''@freezed
sealed class $className with $privateClassName {
  const $className._();

  const factory $className({
${fieldsResult.fields.map((f) => '    $f').join(',\n')},
  }) = $factoryName;

  factory $className.fromJson(Map<String, dynamic> json) => _\$${className}FromJson(json);
}''';

      return ModelClassResult(
        mainClass: mainClass,
        nestedClasses: nestedClasses,
      );
    }

    return ModelClassResult(mainClass: '', nestedClasses: {});
  }

  String _generateImports(String fileName) {
    return '''import 'package:freezed_annotation/freezed_annotation.dart';

import '../../index.dart';

part '$fileName.freezed.dart';
part '$fileName.g.dart';''';
  }

  FieldGenerationResult _generateFieldsWithNested(
      Map<String, dynamic> responseExample, String parentClassName) {
    final fields = <String>[];
    final nestedClasses = <String, String>{};

    for (final entry in responseExample.entries) {
      final fieldName = entry.key;
      final fieldValue = entry.value;
      final dartFieldName = _toCamelCase(fieldName);

      String fieldType;
      String defaultValue;

      if (fieldValue == null) {
        fieldType = 'String?';
        defaultValue = '';
      } else if (fieldValue is String) {
        fieldType = 'String';
        defaultValue = "@Default('')";
      } else if (fieldValue is int) {
        fieldType = 'int';
        defaultValue = '@Default(0)';
      } else if (fieldValue is double) {
        fieldType = 'double';
        defaultValue = '@Default(0.0)';
      } else if (fieldValue is bool) {
        fieldType = 'bool';
        defaultValue = '@Default(false)';
      } else if (fieldValue is List) {
        if (fieldValue.isEmpty) {
          fieldType = 'List<dynamic>';
          defaultValue = '@Default([])';
        } else {
          final itemResult =
              _getListItemTypeWithNested(fieldValue.first, parentClassName, fieldName);
          fieldType = 'List<${itemResult.type}>';
          defaultValue = '@Default([])';
          nestedClasses.addAll(itemResult.nestedClasses);
        }
      } else if (fieldValue is Map<String, dynamic>) {
        final nestedClassName = '${parentClassName}${_toPascalCase(dartFieldName)}';
        fieldType = '$nestedClassName?';
        defaultValue = '';

        // Generate nested class content
        final nestedResult = _generateModelClassWithNested(nestedClassName, fieldValue);
        final nestedImports = _generateImports(_modelNameToFileName(nestedClassName));
        final nestedContent = '''$nestedImports

${nestedResult.mainClass}''';

        nestedClasses[nestedClassName] = nestedContent;
        nestedClasses.addAll(nestedResult.nestedClasses);
      } else {
        fieldType = 'dynamic';
        defaultValue = '';
      }

      final jsonKey = "@JsonKey(name: '$fieldName')";
      final field = fieldType.endsWith('?')
          ? '$jsonKey $fieldType $dartFieldName'
          : '$defaultValue $jsonKey $fieldType $dartFieldName';

      fields.add(field);
    }

    return FieldGenerationResult(fields: fields, nestedClasses: nestedClasses);
  }

  ListItemResult _getListItemTypeWithNested(
      dynamic item, String parentClassName, String fieldName) {
    if (item is String) return ListItemResult(type: 'String', nestedClasses: {});
    if (item is int) return ListItemResult(type: 'int', nestedClasses: {});
    if (item is double) return ListItemResult(type: 'double', nestedClasses: {});
    if (item is bool) return ListItemResult(type: 'bool', nestedClasses: {});

    if (item is Map<String, dynamic>) {
      final itemClassName = '${parentClassName}${_toPascalCase(fieldName)}Item';
      final itemResult = _generateModelClassWithNested(itemClassName, item);
      final itemImports = _generateImports(_modelNameToFileName(itemClassName));
      final itemContent = '''$itemImports

${itemResult.mainClass}''';

      final nestedClasses = <String, String>{itemClassName: itemContent};
      nestedClasses.addAll(itemResult.nestedClasses);

      return ListItemResult(type: itemClassName, nestedClasses: nestedClasses);
    }

    return ListItemResult(type: 'dynamic', nestedClasses: {});
  }

  String _modelNameToFileName(String modelName) {
    if (modelName.isEmpty) return '';

    // Convert PascalCase to snake_case
    var fileName = modelName
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) => '${match[1]}_${match[2]}')
        .toLowerCase();

    return fileName;
  }

  void _writeModelFile(String fileName, String content) {
    final filePath = '$_modelApiPath/$fileName.dart';
    final file = File(filePath);

    // Create directory if it doesn't exist
    file.parent.createSync(recursive: true);

    // Update imports in the content
    final updatedContent = content
        .replaceFirst(
            "part '${_modelNameToFileName('')}.freezed.dart';", "part '$fileName.freezed.dart';")
        .replaceFirst("part '${_modelNameToFileName('')}.g.dart';", "part '$fileName.g.dart';");

    file.writeAsStringSync(updatedContent);
  }

  String _toPascalCase(String input) {
    if (input.isEmpty) return '';

    return input
        .split('_')
        .where((word) => word.isNotEmpty)
        .map((word) => _capitalizeWord(word))
        .join('');
  }

  String _capitalizeWord(String word) {
    if (word.isEmpty) return '';

    // Simple capitalization - first letter uppercase, rest lowercase
    return word[0].toUpperCase() + word.substring(1);
  }

  String _toCamelCase(String input) {
    if (input.isEmpty) return '';

    // Handle cases like 'salary_type' -> 'salaryType' or 'salaryType' -> 'salaryType'
    if (input.contains('_')) {
      // Convert from snake_case
      final parts = input.split('_').where((part) => part.isNotEmpty).toList();
      if (parts.isEmpty) return '';

      final result = parts.first.toLowerCase() +
          parts
              .skip(1)
              .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
              .join('');
      return result;
    } else {
      // Already in camelCase or PascalCase, ensure first letter is lowercase
      return input[0].toLowerCase() + input.substring(1);
    }
  }
}

class EndpointInfo {
  final String method;
  final String path;
  final List<QueryParam> queryParams;
  final bool hasBody;
  final dynamic bodyExample;
  final dynamic responseExample;

  EndpointInfo({
    required this.method,
    required this.path,
    required this.queryParams,
    required this.hasBody,
    this.bodyExample,
    this.responseExample,
  });
}

class QueryParam {
  final String name;
  final String type;
  final bool required;

  QueryParam({
    required this.name,
    required this.type,
    required this.required,
  });
}

class ModelGenerationResult {
  final String mainContent;
  final Map<String, String> nestedClasses;

  ModelGenerationResult({
    required this.mainContent,
    required this.nestedClasses,
  });
}

class ModelClassResult {
  final String mainClass;
  final Map<String, String> nestedClasses;

  ModelClassResult({
    required this.mainClass,
    required this.nestedClasses,
  });
}

class FieldGenerationResult {
  final List<String> fields;
  final Map<String, String> nestedClasses;

  FieldGenerationResult({
    required this.fields,
    required this.nestedClasses,
  });
}

class ListItemResult {
  final String type;
  final Map<String, String> nestedClasses;

  ListItemResult({
    required this.type,
    required this.nestedClasses,
  });
}
