
void main() {
  // expect_lint: avoid_hard_coded_strings
  final a = 'Hello';
  // expect_lint: avoid_hard_coded_strings
  'Hello';
  // expect_lint: avoid_hard_coded_strings
  'a';
  // expect_lint: avoid_hard_coded_strings
  'Hello world $a';
  // expect_lint: avoid_hard_coded_strings
  '''a''';
  // expect_lint: avoid_hard_coded_strings
  '''a
  b
  c''';
  // expect_lint: avoid_hard_coded_strings
  'aaaaa '
      // expect_lint: avoid_hard_coded_strings
      'bbbbb '
      // expect_lint: avoid_hard_coded_strings
      'ccccc';
}

extension StringExtension on String {
  String get hardcoded => this;
}
