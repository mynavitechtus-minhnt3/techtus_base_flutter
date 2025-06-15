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
