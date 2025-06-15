// ignore_for_file: avoid_hard_coded_strings,prefer_single_widget_per_file
import 'package:freezed_annotation/freezed_annotation.dart';

class User {
  const factory User({
    @Default(<String>[]) List<String> list,
    @Default(<String>{}) Set<String> set1,
    @Default(<String, String>{}) Map<String, String> map,
    @Default('') String string,
    @Default(0) int integer,
    @Default(0.0) double decimal,
    @Default(0.0) num num1,
    @Default(false) bool boolean,
    @Default(null) DateTime? dateTime,
    @Default(DemoObject()) DemoObject demoObject,
    //expect_lint: incorrect_freezed_default_value_type
    @Default(0) List<String> list2,
    //expect_lint: incorrect_freezed_default_value_type
    @Default('') Set<String> set2,
    //expect_lint: incorrect_freezed_default_value_type
    @Default(null) Map<String, String> map2,
    //expect_lint: incorrect_freezed_default_value_type
    @Default('') int string2,
    //expect_lint: incorrect_freezed_default_value_type
    @Default(0) bool integer2,
    //expect_lint: incorrect_freezed_default_value_type
    @Default(0.0) String decimal2,
    //expect_lint: incorrect_freezed_default_value_type
    @Default(0.0) int num2,
    //expect_lint: incorrect_freezed_default_value_type
    @Default(false) num boolean2,
    //expect_lint: incorrect_freezed_default_value_type
    @Default(null) DemoObject dateTime2,
    //expect_lint: incorrect_freezed_default_value_type
    @Default(DemoObject()) DemoObject2 demoObject2,
  }) = _User;
}

class _User implements User {
  const _User({
    List<String>? list,
    Set<String>? set1,
    Map<String, String>? map,
    String? string,
    int? integer,
    double? decimal,
    num? num1,
    bool? boolean,
    DateTime? dateTime,
    DemoObject? demoObject,
    List<String>? list2,
    Set<String>? set2,
    Map<String, String>? map2,
    int? string2,
    bool? integer2,
    String? decimal2,
    int? num2,
    num? boolean2,
    DemoObject? dateTime2,
    DemoObject2? demoObject2,
  })  : _list = list ?? const <String>[],
        _set1 = set1 ?? const <String>{},
        _map = map ?? const <String, String>{},
        _string = string ?? '',
        _integer = integer ?? 0,
        _decimal = decimal ?? 0.0,
        _num1 = num1 ?? 0.0,
        _boolean = boolean ?? false,
        _dateTime = dateTime,
        _demoObject = demoObject ?? const DemoObject(),
        _list2 = list2 ?? const <String>[],
        _set2 = set2 ?? const <String>{},
        _map2 = map2 ?? const <String, String>{},
        _string2 = string2 ?? 1,
        _integer2 = integer2 ?? false,
        _decimal2 = decimal2 ?? '',
        _num2 = num2 ?? 0,
        _boolean2 = boolean2 ?? 1,
        _dateTime2 = dateTime2,
        _demoObject2 = demoObject2 ?? const DemoObject2();

  final List<String> _list;
  final Set<String> _set1;
  final Map<String, String> _map;
  final String _string;
  final int _integer;
  final double _decimal;
  final num _num1;
  final bool _boolean;
  final DateTime? _dateTime;
  final DemoObject _demoObject;
  final List<String> _list2;
  final Set<String> _set2;
  final Map<String, String> _map2;
  final int _string2;
  final bool _integer2;
  final String _decimal2;
  final int _num2;
  final num _boolean2;
  final DemoObject? _dateTime2;
  final DemoObject2 _demoObject2;

  List<String> get list => _list;

  Set<String> get set1 => _set1;

  Map<String, String> get map => _map;

  String get string => _string;

  int get integer => _integer;

  double get decimal => _decimal;

  num get num1 => _num1;

  bool get boolean => _boolean;

  DateTime? get dateTime => _dateTime;

  DemoObject get demoObject => _demoObject;

  List<String> get list2 => _list2;

  Set<String> get set2 => _set2;

  Map<String, String> get map2 => _map2;

  int get string2 => _string2;

  bool get integer2 => _integer2;

  String get decimal2 => _decimal2;

  int get num2 => _num2;

  num get boolean2 => _boolean2;

  DemoObject? get dateTime2 => _dateTime2;

  DemoObject2 get demoObject2 => _demoObject2;
}

class DemoObject {
  const DemoObject();
}

class DemoObject2 {
  const DemoObject2();
}
