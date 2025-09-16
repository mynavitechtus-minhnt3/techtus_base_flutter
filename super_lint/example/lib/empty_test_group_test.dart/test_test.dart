//ignore_for_file: avoid_hard_coded_strings, prefer_named_parameters
// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD BE WARNED ~.~.~.~.~.~.~.~

void main() {
  // expect_lint: empty_test_group
  group('design', () {});
}

// Helper functions
void group(String name, Function body) {}
void testGoldens(String description, Function body) {}
void testWidgets(String description, Function body) {}
