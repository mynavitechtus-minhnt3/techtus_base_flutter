// ignore_for_file: prefer_single_widget_per_file, avoid_hard_coded_strings
abstract class AnalyticParameter {
  Map<String, Object>? get parameters;
}

class MyParameter extends AnalyticParameter {
  Map<String, Object>? get parameters => {
        'string': 'value',
        'int': 1,
        'double': 1.0,
        // expect_lint: incorrect_event_parameter_type
        'list': [],
        // expect_lint: incorrect_event_parameter_type
        'map': {'key': 'value'},
        // expect_lint: incorrect_event_parameter_type
        'set': {1, 2, 3},
        // expect_lint: incorrect_event_parameter_type
        'bool': true,
        // expect_lint: incorrect_event_parameter_type
        'null': DateTime.now(),
      };
}

class ParameterConstants {
  ParameterConstants._();

  static const String recommendType = 'recommend_type_1';
  static const String uniqueCode = 'unique_code';
  static const String title = 'title';
  static const String isFavorite = 'is_favorite';
  static const String isViewed = 'is_viewed';
  static const String from = 'from';
  static const String order = 'order';
  static const String rank = 'rank';
  static const String areaCount = 'area_count';
  static const String timestamp = 'timestamp';
  static const String appUserOs = 'app_user_os';
}

class Work {
  Work({
    required this.uniqueCode,
    required this.title,
  });

  final int uniqueCode;
  final String title;
}

// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD NOT BE WARNED ~.~.~.~.~.~.~.~
class CommonWorkParameter extends AnalyticParameter {
  CommonWorkParameter({
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
        ParameterConstants.isFavorite: isFavorite.toString(),
        ParameterConstants.isViewed: isViewed.toString(),
      };
}

/// specific parameter classes

class WorkAndSearchConditionParameter extends AnalyticParameter {
  WorkAndSearchConditionParameter({
    required this.workParameter,
  });

  final CommonWorkParameter workParameter;

  @override
  Map<String, Object>? get parameters => {
        ...?workParameter.parameters,
      };
}

class WorkAndFromParameter extends AnalyticParameter {
  WorkAndFromParameter({
    required this.workParameter,
    required this.from,
  });

  final CommonWorkParameter workParameter;
  final String from;

  @override
  Map<String, Object>? get parameters => {
        ...?workParameter.parameters,
        ParameterConstants.from: from,
      };
}

class RecommendCardFavoriteSwipeParameter extends AnalyticParameter {
  RecommendCardFavoriteSwipeParameter({
    required this.workParameter,
    required this.order,
    required this.rank,
    required this.areaCount,
    required this.recommendType,
  });

  final CommonWorkParameter workParameter;
  final int order;
  final double rank;
  final int areaCount;
  final String recommendType;

  @override
  Map<String, Object>? get parameters => {
        ...?workParameter.parameters,
        ParameterConstants.order: order,
        ParameterConstants.rank: rank,
        ParameterConstants.areaCount: areaCount,
        ParameterConstants.recommendType: recommendType,
      };
}

class InstructionFirstStepDisplayParameter extends AnalyticParameter {
  InstructionFirstStepDisplayParameter({
    required this.timestamp,
    required this.appUserOs,
  });

  final int timestamp;
  final String appUserOs;

  @override
  Map<String, Object>? get parameters => {
        ParameterConstants.timestamp: timestamp,
        ParameterConstants.appUserOs: appUserOs,
      };
}

// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD BE WARNED ~.~.~.~.~.~.~.~
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
