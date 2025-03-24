import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../index.dart';

part 'home_state.freezed.dart';

@freezed
sealed class HomeState extends BaseState with _$HomeState {
  const HomeState._();
  
  factory HomeState({
    @Default(LoadMoreOutput<ApiUserData>(data: <ApiUserData>[])) LoadMoreOutput<ApiUserData> users,
    @Default(false) bool isShimmerLoading,
    AppException? loadUsersException,
  }) = _HomeState;
}
