import 'package:freezed_annotation/freezed_annotation.dart';

import '../../index.dart';

part 'common_state.freezed.dart';

@freezed
sealed class CommonState<T extends BaseState> with _$CommonState<T> {
  const CommonState._();

  const factory CommonState({
    required T data,
    AppException? appException,
    @Default(false) bool isLoading,
    @Default(false) bool isFirstLoading,
    @Default(<String, bool>{}) Map<String, bool> doingAction,
  }) = _CommonState;

  bool isDoingAction(String actionName) => doingAction[actionName] == true;
}
