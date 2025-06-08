import 'dart:io';

Future<void> main(List<String> args) async {
  final modules = args;

  var hasError = false;

  for (final path in modules) {
    print('🔍 Running super_lint for $path ...');

    final result = await Process.run(
      'dart',
      ['run', 'custom_lint'],
      workingDirectory: path,
      runInShell: true,
    );

    final output = result.stdout.toString();
    print(output);

    if (output.contains(' • INFO')) {
      print('❌ $path: Failed: Info found.');
      hasError = true;
    }

    if (output.contains(' • WARNING')) {
      print('❌ $path: Failed: Warning found.');
      hasError = true;
    }

    if (output.contains(' • ERROR')) {
      print('❌ $path: Failed: Error found.');
      hasError = true;
    }

    if (!hasError) {
      print('✅ $path: Passed.');
    }

    print('');
  }

  if (hasError) {
    print('super_lint: Failed on at least one module.');
    exit(1);
  } else {
    print('*** super_lint: Success. ***');
  }
}
