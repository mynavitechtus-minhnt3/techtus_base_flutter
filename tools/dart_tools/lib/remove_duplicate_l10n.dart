// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_print
import 'dart:io';

import 'package:dartx/dartx.dart';

void main(List<String> args) {
  final l10nPath = args[0];

  Directory(l10nPath).listSync().forEach((file) {
    final langCode = file.path.split('/').last.split('.').first.split('_').last;
    final listL10n = convertArbToListL10n(File(file.path).readAsStringSync());
    final countValueMap = groupByValue(listL10n);
    File(file.path).writeAsStringSync("{\n  \"@@locale\": \"$langCode\",\n${listL10n.map((l10n) {
      final line =
          (countValueMap[l10n.value]?.$1 ?? 0) >= 2 ? l10n.copyWith(isDupValue: true) : l10n;

      return line;
    }).join(",\n")}\n}\n");
    final duplicateValues = filterValueDuplicates(countValueMap);
    final duplicateKeys = filterKeyDuplicates(listL10n);
    if (duplicateValues.isEmpty && duplicateKeys.isEmpty) {
      print('No duplicate l10n keys or values found. 🎉');
      exit(0);
    } else {
      if (duplicateKeys.isNotEmpty) print('Dup l10n keys of ${file.path}:\n$duplicateKeys');
      if (duplicateValues.isNotEmpty) print('Dup l10n values of ${file.path}:\n$duplicateValues');
      exit(1);
    }
  });
}

List<L10n> convertArbToListL10n(String arbText) {
  return arbText
      .split(',\n')
      .map((it) {
        final match = RegExp(r'(.*)"(\w+)" *: *"(.+)"').firstMatch(it);

        return match?.groups([0, 1, 2, 3]) ?? [];
      })
      .where((it) => it.isNotEmpty)
      .map((it) {
        return L10n(key: it[2]!, value: it[3]!, comment: it[1]!);
      })
      .toList();
}

Map<String, (int, List<String>)> groupByValue(List<L10n> listL10n) {
  final countValueMap = <String, (int, List<String>)>{};
  for (var l10n in listL10n) {
    countValueMap[l10n.value] = (
      (countValueMap[l10n.value]?.$1 ?? 0) + 1,
      countValueMap[l10n.value]?.$2.appendElement(l10n.key).toList() ?? [l10n.key],
    );
  }

  return countValueMap;
}

String filterValueDuplicates(Map<String, (int, List<String>)> countValueMap) {
  final dups = countValueMap.filter((entry) => entry.value.$1 >= 2);
  String result = '';

  for (var dup in dups.entries) {
    result += '* "${dup.key}" (${dup.value.$1}): ${dup.value.$2}\n';
  }

  return result;
}

String filterKeyDuplicates(List<L10n> listL10n) {
  final countKeyMap = <String, int>{};
  for (var l10n in listL10n) {
    countKeyMap[l10n.key] = (countKeyMap[l10n.key] ?? 0) + 1;
  }

  final dups = countKeyMap.filter((entry) => entry.value >= 2);
  String result = '';

  for (var dup in dups.entries) {
    result += '* "${dup.key}" (${dup.value})\n';
  }

  return result;
}

class L10n {
  L10n({
    required this.key,
    required this.value,
    required this.comment,
    this.isDupValue = false,
  });

  final String key;
  final String value;
  final String comment;
  final bool isDupValue;

  @override
  String toString() {
    final commentPrefix = isDupValue && !comment.trimLeft().startsWith('//') ? '//' : '';
    final line = '$commentPrefix $comment "${key}": "${value}"'.trim();

    return !line.startsWith('//') ? '  $line' : line;
  }

  L10n copyWith({
    String? key,
    String? value,
    String? comment,
    bool? isDupValue,
  }) {
    return L10n(
      key: key ?? this.key,
      value: value ?? this.value,
      comment: comment ?? this.comment,
      isDupValue: isDupValue ?? this.isDupValue,
    );
  }
}
