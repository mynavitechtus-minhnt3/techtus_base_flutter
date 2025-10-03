// ignore_for_file: incorrect_parent_class
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../index.dart';

part 'my_profile_state.freezed.dart';

@freezed
class MyProfileState extends BaseState with _$MyProfileState {
  const MyProfileState._();

  const factory MyProfileState() = _MyProfileState;
}
