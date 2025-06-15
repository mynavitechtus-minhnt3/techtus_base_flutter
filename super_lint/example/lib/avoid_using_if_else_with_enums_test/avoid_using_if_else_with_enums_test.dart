enum TestEnum {
  test1,
  test2,
  test3,
}

// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD NOT BE WARNED ~.~.~.~.~.~.~.~
void test() {
  TestEnum testEnum = TestEnum.test1;
  switch (testEnum) {
    case TestEnum.test1:
      print(1);
      break;
    case TestEnum.test2:
      print(2);
      break;
    case TestEnum.test3:
      print(3);
      break;
  }
}

// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD BE WARNED ~.~.~.~.~.~.~.~
void test2() {
  TestEnum testEnum = TestEnum.test1;
  // expect_lint: avoid_using_if_else_with_enums
  if (testEnum == TestEnum.test1) {
    print(1);
    // expect_lint: avoid_using_if_else_with_enums
  } else if (testEnum == TestEnum.test2) {
    print(2);
    // expect_lint: avoid_using_if_else_with_enums
  } else if (testEnum == TestEnum.test3) {
    print(3);
  }

  // expect_lint: avoid_using_if_else_with_enums
  testEnum == TestEnum.test2 ? 2 : 1;
}
