class AnalyticParameter {}

class MyParameter extends AnalyticParameter {
  // expect_lint: incorrect_event_parameter_type
  Map<String, dynamic> get parameters => {'list': []};
}
