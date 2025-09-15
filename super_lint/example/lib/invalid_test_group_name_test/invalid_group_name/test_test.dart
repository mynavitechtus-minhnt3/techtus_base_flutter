//ignore_for_file: avoid_hard_coded_strings, prefer_named_parameters
// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD BE WARNED ~.~.~.~.~.~.~.~

// Invalid group name
// expect_lint: invalid_test_group_name
void main() {
  group('invalid_group', () {
    testGoldens('invalid group test', () {});
  });
}

// Helper functions
void group(String name, Function body) {}
void testGoldens(String description, Function body) {}
void testWidgets(String description, Function body) {}
