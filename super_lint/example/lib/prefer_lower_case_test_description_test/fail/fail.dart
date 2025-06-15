
void group() {
  // expect_lint: prefer_lower_case_test_description
  test('Uppercase text', () {});
  // expect_lint: prefer_lower_case_test_description
  blocTest('Uppercase text', () {});
}

void test(String description, Function body) {}
void blocTest(String desc, Function body) {}
void stateNotifierTest(String description, Function body) {}
