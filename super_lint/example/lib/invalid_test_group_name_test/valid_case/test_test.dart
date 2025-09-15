// ignore_for_file: prefer_named_parameters, avoid_hard_coded_strings
// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD NOT BE WARNED ~.~.~.~.~.~.~.~

void main() {
  group('design', () {
    testGoldens('valid design test', () {});
  });

  group('others', () {
    testGoldens('valid widget test', () {});
  });
}

// Helper functions
void group(String name, Function body) {}
void testGoldens(String description, Function body) {}
void testWidgets(String description, Function body) {}
