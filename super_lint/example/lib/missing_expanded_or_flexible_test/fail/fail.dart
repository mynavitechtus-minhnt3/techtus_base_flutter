void test() {
  // expect_lint: missing_expanded_or_flexible
  Row(
    children: [
      SizedBox(),
      SizedBox(),
    ],
  );
  // expect_lint: missing_expanded_or_flexible
  Row(
    children: [
      SizedBox(),
      SizedBox(),
      SizedBox(),
    ],
  );
  // expect_lint: missing_expanded_or_flexible
  Column(
    children: [
      SizedBox(),
      SizedBox(),
    ],
  );
  // expect_lint: missing_expanded_or_flexible
  Column(
    children: [
      SizedBox(),
      SizedBox(),
      SizedBox(),
    ],
  );
}
