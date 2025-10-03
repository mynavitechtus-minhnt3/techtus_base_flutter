import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../index.dart';

part 'load_more_example_state.freezed.dart';

@freezed
sealed class LoadMoreExampleState extends BaseState with _$LoadMoreExampleState {
  const LoadMoreExampleState._();

  factory LoadMoreExampleState({
    @Default(LoadMoreOutput<ApiUserData>(data: <ApiUserData>[])) LoadMoreOutput<ApiUserData> users,
    @Default(false) bool isShimmerLoading,
    AppException? loadUsersException,
  }) = _LoadMoreExampleState;
}
