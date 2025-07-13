import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../index.dart';

final splashViewModelProvider =
    StateNotifierProvider.autoDispose<SplashViewModel, CommonState<SplashState>>(
  (ref) => SplashViewModel(ref),
);

class SplashViewModel extends BaseViewModel<SplashState> {
  SplashViewModel(this.ref) : super(const CommonState(data: SplashState()));

  final Ref ref;

  Future<void> init() async {
    await runCatching(
      action: () async {
        await Future.delayed(const Duration(milliseconds: 1000));
        if (ref.appPreferences.isLoggedIn) {
          FlutterNativeSplash.remove();
          await ref.nav.replaceAll([MainRoute()]);
        } else {
          FlutterNativeSplash.remove();
          await ref.nav.replaceAll([const LoginRoute()]);
        }
      },
    );
  }
}
