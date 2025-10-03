import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../index.dart';

part 'home_state.freezed.dart';

@freezed
sealed class HomeState extends BaseState with _$HomeState {
  const HomeState._();

  const factory HomeState({
    @Default('') String keyword,
    @Default(<FirebaseConversationData>[]) List<FirebaseConversationData> conversationList,
  }) = _HomeState;
}
