// expect_lint: util_functions_must_be_static
void test() {}

// expect_lint: util_functions_must_be_static
void get(String url) {
  print(url);
}

// expect_lint: util_functions_must_be_static
void post() {}

// expect_lint: util_functions_must_be_static
void request(String url) {
  print(url);
}
