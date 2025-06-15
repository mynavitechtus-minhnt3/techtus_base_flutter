enum ScreenName {
  // expect_lint: incorrect_screen_name_enum_value
  somePage(screenEventPrefix: 'wrong', screenClass: 'Wrong');

  const ScreenName({required this.screenEventPrefix, required this.screenClass});
  final String screenEventPrefix;
  final String screenClass;
}
