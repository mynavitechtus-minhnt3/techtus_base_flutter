class CommonWorkParameter2 extends AnalyticParameter {
  CommonWorkParameter2({
    required this.work,
    required this.isFavorite,
    required this.isViewed,
  });

  final Work work;
  final bool isFavorite;
  final bool isViewed;

  @override
  Map<String, Object>? get parameters => {
        ParameterConstants.uniqueCode: work.uniqueCode,
        ParameterConstants.title: work.title,
        // expect_lint: incorrect_event_parameter_type
        ParameterConstants.isFavorite: isFavorite,
        // expect_lint: incorrect_event_parameter_type
        ParameterConstants.isViewed: isViewed,
      };
}
