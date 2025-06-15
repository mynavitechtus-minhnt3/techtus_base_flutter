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

// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD BE WARNED ~.~.~.~.~.~.~.~
final fourLevels = str.isEmpty
    ? str.isEmpty
        ? str.isEmpty
            // expect_lint: avoid_nested_conditions
            ? str.isEmpty
                ? 'hihihihi'
                : '1'
            : '1'
        : '2'
    : '3';

void main() {
  if (3 > 2) {
    if (2 > 1) {
      if (1 > 0) {
        // expect_lint: avoid_nested_conditions
        if (true) {}
      }
    }
  }

  if (3 > 2) {
    if (2 > 1) {
      if (1 > 0) {
        // expect_lint: avoid_nested_conditions
        if ('a'.isEmpty) {
          // expect_lint: avoid_nested_conditions
          if (true) {}
        }
      }
    }
  }
}
