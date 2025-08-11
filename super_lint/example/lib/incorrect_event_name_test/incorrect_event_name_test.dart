// ignore_for_file: require_matching_file_and_class_name,prefer_single_widget_per_file, avoid_hard_coded_strings
class EventConstants {
  static const String value = 'value';
  static const String value2 = 'value2';
  static const String value3 = 'value_3';
  static const String snakeCase = 'value_snake_case';
  static const number = 1;
  static const number2 = '1';

  // expect_lint: incorrect_event_name
  static const String camelCase = 'valueCamel';
  // expect_lint: incorrect_event_name
  static const upperCase = 'VALUE';
  // expect_lint: incorrect_event_name
  static const kebabCase = 'value-kebab-case';
  // expect_lint: incorrect_event_name
  static const String pascalCase = 'ValueCamelCase';
}
