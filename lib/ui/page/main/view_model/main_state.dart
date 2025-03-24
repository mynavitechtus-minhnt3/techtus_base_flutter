import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../index.dart';

part 'main_state.freezed.dart';

@freezed
sealed class MainState extends BaseState with _$MainState {
  const MainState._();

  const factory MainState() = _MainState;
}
