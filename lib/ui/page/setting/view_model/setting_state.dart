import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../index.dart';

part 'setting_state.freezed.dart';

@freezed
sealed class SettingState extends BaseState with _$SettingState {
  const SettingState._();
  
  const factory SettingState() = _SettingState;
}
