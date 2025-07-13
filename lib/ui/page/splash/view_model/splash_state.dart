import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../index.dart';

part 'splash_state.freezed.dart';

@freezed
sealed class SplashState extends BaseState with _$SplashState {
  const SplashState._();

  const factory SplashState({
    @Default('') String id,
  }) = _SplashState;
}
