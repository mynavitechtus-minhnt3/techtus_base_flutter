// ignore_for_file: avoid_hard_coded_strings
enum ScreenName {
  // expect_lint: incorrect_screen_name_enum_value
  registerTestPage(screenEventPrefix: 'register', screenClass: 'RegisterTestPage'),
  // expect_lint: incorrect_screen_name_enum_value
  dummyTestPage(screenEventPrefix: 'dummy_test', screenClass: 'DummyPage'),
  loginTestPage(screenEventPrefix: 'login_test', screenClass: 'LoginTestPage');

  const ScreenName({required this.screenEventPrefix, required this.screenClass});
  final String screenEventPrefix;
  final String screenClass;
}
