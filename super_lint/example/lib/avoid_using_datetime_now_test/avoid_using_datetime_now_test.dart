// ignore_for_file: avoid_dynamic, avoid_hard_coded_strings, require_matching_file_and_class_name
// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD NOT BE WARNED ~.~.~.~.~.~.~.~

DateTime get now => DateTime(0);

void main() {
  // ignore: unused_local_variable
  final current = now;
}

// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD BE WARNED ~.~.~.~.~.~.~.~
void test() {
  // expect_lint: avoid_using_datetime_now
  final current = DateTime.now();
  print(current);
}

class Clock {
  // expect_lint: avoid_using_datetime_now
  DateTime now() => DateTime.now();
}

final clock = Clock();
