// ignore_for_file: avoid_hard_coded_strings

import 'package:freezed_annotation/freezed_annotation.dart';

part 'incorrect_freezed_default_value_type_test.freezed.dart';

@freezed
class User with _$User {
  const factory User({
    @Default(<String>[]) List<String> names,
  }) = _User;
}

@freezed
class Contact with _$Contact {
  const factory Contact({
    // expect_lint: incorrect_freezed_default_value_type
    @Default(0) List<String> phones,
  }) = _Contact;
}
