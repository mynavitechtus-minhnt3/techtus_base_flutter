//ignore_for_file: avoid_hard_coded_strings, prefer_named_parameters
// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD BE WARNED ~.~.~.~.~.~.~.~

// Missing required groups
// expect_lint: missing_test_group
void main() {
  group('design', () {
    testGoldens('valid design test', () {});
  });
  // Missing 'others' group
}

// Helper functions
void group(String name, Function body) {}
void testGoldens(String description, Function body) {}
void testWidgets(String description, Function body) {}
