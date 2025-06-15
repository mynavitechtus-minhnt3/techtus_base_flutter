// ignore_for_file: prefer_single_widget_per_file
class BasePage {}

class AnalyticsHelper {}

// expect_lint: missing_extension_method_for_events
extension AnalyticsHelperOnATestPage on AnalyticsHelper {}

class CTestPage extends BasePage {}
