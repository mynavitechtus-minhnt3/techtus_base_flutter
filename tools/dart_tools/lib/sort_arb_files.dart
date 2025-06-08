import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  final arbFiles = Directory(args[0])
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.arb'))
      .map((e) => e.path)
      .toList();

  for (var arbFile in arbFiles) {
    await sortArbFile(arbFile);
  }

  print('All .arb files have been sorted and formatted.');
}

Future<void> sortArbFile(String filePath) async {
  final file = File(filePath);

  if (!await file.exists()) {
    print('File does not exist: $filePath');
    return;
  }

  final content = await file.readAsString();
  final Map<String, dynamic> data = json.decode(content);

  final sortedData = Map.fromEntries(
    data.entries.toList()..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase())),
  );

  // Pretty-print the sorted content with indentation
  final sortedContent = JsonEncoder.withIndent('  ').convert(sortedData);

  await file.writeAsString(sortedContent + '\n');
  print('File sorted and formatted: $filePath');
}
