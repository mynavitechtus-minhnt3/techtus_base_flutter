// ignore_for_file: prefer_single_widget_per_file, avoid_hard_coded_strings
// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD BE WARNED ~.~.~.~.~.~.~.~
class ScreenViewEvent {
  final ScreenName screenName;

  ScreenViewEvent({
    required this.screenName,
  });
}

class NormalEvent {
  final ScreenName screenName;

  NormalEvent({
    required this.screenName,
  });
}

enum ScreenName {
  loginTestPage,
  registerTestPage,
}

class FirebaseAnalyticsHelper {
  void logEvent({required NormalEvent event}) {
    print('logEvent: $event');
  }

  void logScreenView({
    required ScreenViewEvent screenViewEvent,
  }) {
    print('logScreenView: $screenViewEvent');
  }
}

abstract class BasePage {
  ScreenViewEvent get screenViewEvent;
}

extension AnalyticsHelperOnRegisterTestPage on FirebaseAnalyticsHelper {
  void logRegisterEvent() {
    // expect_lint: incorrect_screen_name_parameter_value
    logEvent(event: NormalEvent(screenName: ScreenName.loginTestPage));
  }

  void logRegisterScreenView() {
    // expect_lint: incorrect_screen_name_parameter_value
    logScreenView(screenViewEvent: ScreenViewEvent(screenName: ScreenName.loginTestPage));
  }
}

// ignore: missing_extension_method_for_events
class RegisterTestPage extends BasePage {
  @override
  // expect_lint: incorrect_screen_name_parameter_value
  ScreenViewEvent get screenViewEvent => ScreenViewEvent(screenName: ScreenName.loginTestPage);
}
