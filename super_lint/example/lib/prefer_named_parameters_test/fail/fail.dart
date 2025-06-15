
class B {
  final String a;
  final String b;

  // expect_lint: prefer_named_parameters
  B(this.a, this.b);
  // expect_lint: prefer_named_parameters
  B.a(this.a, [this.b = '']);
  // expect_lint: prefer_named_parameters
  B.b(this.a, {this.b = ''});
  // expect_lint: prefer_named_parameters
  B.c(this.a, {required this.b});
  // expect_lint: prefer_named_parameters
  B.d(this.a, String? b) : b = b ?? '';
}

// expect_lint: prefer_named_parameters
void test4(String a, String b) {}

// expect_lint: prefer_named_parameters
void test5(String a, [String b = '']) {}

// expect_lint: prefer_named_parameters
void test6(String a, {required String b}) {}

// expect_lint: prefer_named_parameters
void test7(String a, {String b = ''}) {}

// expect_lint: prefer_named_parameters
void test8(String a, {String? b}) {}

// expect_lint: prefer_named_parameters
void test9([String? a, String? b = '']) {}
