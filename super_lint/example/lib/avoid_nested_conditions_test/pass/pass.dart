// ignore_for_file: avoid_hard_coded_strings
// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD NOT BE WARNED ~.~.~.~.~.~.~.~
final str = '';

final oneLevel = str.isEmpty ? 'hi' : '1';

final twoLevels = str.isEmpty
    ? str.isEmpty
        ? 'hihi'
        : '1'
    : '2';

final threeLevels = str.isEmpty
    ? str.isEmpty
        ? str.isEmpty
            ? 'hihihi'
            : '1'
        : '2'
    : '3';

void test() {
  if (true) {}

  if (3 > 2) {
    if (2 > 1) {}
  }

  if (3 > 2) {
    if (2 > 1) {
      if (1 > 0) {}
    }
  }
}

