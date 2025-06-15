void test() {
  // expect_lint: avoid_using_text_style_constructor_directly
  Text('Hello, World!', style: TextStyle(color: Colors.black));
  // expect_lint: avoid_using_text_style_constructor_directly
  TextStyle(color: Colors.black);
}
