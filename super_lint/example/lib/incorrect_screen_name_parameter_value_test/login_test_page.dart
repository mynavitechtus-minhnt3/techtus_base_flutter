// ignore_for_file: prefer_single_widget_per_file, avoid_hard_coded_strings
// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD NOT BE WARNED ~.~.~.~.~.~.~.~
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

extension AnalyticsHelperOnLoginTestPage on FirebaseAnalyticsHelper {
  void logLoginEvent() {
    logEvent(event: NormalEvent(screenName: ScreenName.loginTestPage));
  }

  void logLoginScreenView() {
    logScreenView(screenViewEvent: ScreenViewEvent(screenName: ScreenName.loginTestPage));
  }
}

// ignore: missing_extension_method_for_events
class LoginTestPage extends BasePage {
  @override
  ScreenViewEvent get screenViewEvent => ScreenViewEvent(screenName: ScreenName.loginTestPage);
}
