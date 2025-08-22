// ignore_for_file: avoid_dynamic, avoid_hard_coded_strings
// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD NOT BE WARNED ~.~.~.~.~.~.~.~

DateTime get now => DateTime(0);

void main() {
  final current = now;
}

// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD BE WARNED ~.~.~.~.~.~.~.~
void test() {
  // expect_lint: avoid_using_datetime_now
  final current = DateTime.now();
  print(current);
}

