//ignore_for_file: avoid_hard_coded_strings, prefer_named_parameters, missing_test_group
// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD BE WARNED ~.~.~.~.~.~.~.~

// Invalid group name
void main() {
  // expect_lint: invalid_test_group_name
  group('invalid_group', () {
    testGoldens('invalid group test', () {});
  });
}

// Helper functions
void group(String name, Function body) {}
void testGoldens(String description, Function body) {}
void testWidgets(String description, Function body) {}
