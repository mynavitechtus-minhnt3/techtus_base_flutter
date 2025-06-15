enum ScreenName { otherScreen }

void navigate({required ScreenName screenName}) {}

void main() {
  // expect_lint: incorrect_screen_name_parameter_value
  navigate(screenName: ScreenName.otherScreen);
}
