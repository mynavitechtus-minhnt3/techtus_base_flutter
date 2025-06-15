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

