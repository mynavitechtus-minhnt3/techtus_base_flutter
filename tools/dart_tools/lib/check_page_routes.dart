// ignore_for_file: avoid_print

import 'dart:io';

/// Check if all pages in lib/ui/page have corresponding routes in app_router.dart
/// Usage: dart run tools/dart_tools/lib/check_page_routes.dart
/// Exit code 0: All pages have routes
/// Exit code 1: Missing routes found

// Pages that should be ignored during route checking
// Add page names (without _page.dart suffix) that don't need route validation
const List<String> _excludedPages = [
  'my_page', // MyPageRoute is handled differently as a nested route
];

void main(List<String> args) async {
  final skipError = args.contains('--skip-error');
  print('🔍 Checking page routes consistency...');

  final pageDir = Directory('lib/ui/page');
  final routerFile = File('lib/navigation/routes/app_router.dart');

  if (!await pageDir.exists()) {
    print('❌ Page directory not found: lib/ui/page');
    exit(1);
  }

  if (!await routerFile.exists()) {
    print('❌ Router file not found: lib/navigation/routes/app_router.dart');
    exit(1);
  }

  // Get all page files
  final pageFiles = await _getPageFiles(pageDir);
  if (pageFiles.isEmpty) {
    print('✅ No page files found in lib/ui/page');
    return;
  }

  // Read router content
  final routerContent = await routerFile.readAsString();

  // Check each page file
  final missingRoutes = <String>[];
  final foundRoutes = <String>[];
  final excludedRoutes = <String>[];

  for (final pageFile in pageFiles) {
    final pageName = _getPageNameFromFile(pageFile);

    // Skip excluded pages
    if (_excludedPages.contains(pageName)) {
      excludedRoutes.add(pageName);
      print('⏭️  Skipped excluded page: $pageName');
      continue;
    }

    final routeName = _convertPageNameToRouteName(pageName);

    if (_hasRoute(routerContent, routeName)) {
      foundRoutes.add('$pageName -> $routeName');
      print('✅ $pageName has route: $routeName');
    } else {
      missingRoutes.add('$pageName -> $routeName');
      print('❌ $pageName missing route: $routeName');
    }
  }

  print('\n📊 Summary:');
  print('   Found routes: ${foundRoutes.length}');
  print('   Excluded pages: ${excludedRoutes.length}');
  print('   Missing routes: ${missingRoutes.length}');

  if (missingRoutes.isNotEmpty) {
    print('\n❌ Missing routes detected:');
    for (final missing in missingRoutes) {
      print('   • $missing');
    }
    print('\n💡 Please add the missing routes to lib/navigation/routes/app_router.dart');
    if (skipError) {
      print('Skip error mode: Continuing despite missing routes');
    } else {
      exit(1);
    }
  }

  print('\n✅ All pages have corresponding routes in app_router.dart');
}

Future<List<String>> _getPageFiles(Directory pageDir) async {
  final pageFiles = <String>[];

  await for (final entity in pageDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('_page.dart')) {
      // Skip if it's in a subdirectory like view_model
      final relativePath = entity.path.substring(pageDir.path.length + 1);
      if (!relativePath.contains('/') || relativePath.split('/').length == 2) {
        pageFiles.add(entity.path);
      }
    }
  }

  pageFiles.sort();
  return pageFiles;
}

String _getPageNameFromFile(String filePath) {
  final fileName = filePath.split('/').last;
  // Remove .dart suffix to get the full page name including _page
  return fileName.replaceAll('.dart', '');
}

String _convertPageNameToRouteName(String pageName) {
  // Convert snake_case to PascalCase following AutoRoute convention
  // AutoRoute replaces "Page" with "Route" due to @AutoRouterConfig(replaceInRouteName: 'Page,Route')
  // e.g. login_page -> LoginPage -> LoginRoute, my_page -> MyPage -> MyRoute
  final words = pageName.split('_');
  final pascalCase = words
      .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join('');

  // AutoRoute replaces "Page" suffix with "Route"
  if (pascalCase.endsWith('Page')) {
    return pascalCase.replaceAll(RegExp(r'Page$'), 'Route');
  }

  // If no "Page" suffix, add "Route"
  return '${pascalCase}Route';
}

bool _hasRoute(String routerContent, String routeName) {
  // Look for patterns like:
  // - AutoRoute(page: SomeRoute.page)
  // - buildCustomRoute(page: SomeRoute.page)
  // - page: SomeRoute.page
  final patterns = [
    RegExp(r'AutoRoute\s*\(\s*page:\s*' + routeName + r'\.page'),
    RegExp(r'buildCustomRoute\s*\([^)]*page:\s*' + routeName + r'\.page'),
    RegExp(r'page:\s*' + routeName + r'\.page'),
  ];

  return patterns.any((pattern) => pattern.hasMatch(routerContent));
}
