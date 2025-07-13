import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../index.dart';

@RoutePage()
class SplashPage extends BasePage<SplashState,
    AutoDisposeStateNotifierProvider<SplashViewModel, CommonState<SplashState>>> {
  const SplashPage({super.key});

  @override
  ScreenViewEvent get screenViewEvent => ScreenViewEvent(screenName: ScreenName.splashPage);

  @override
  AutoDisposeStateNotifierProvider<SplashViewModel, CommonState<SplashState>> get provider =>
      splashViewModelProvider;

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    useEffect(
      () {
        Future.microtask(() {
          ref.read(provider.notifier).init();
        });

        return null;
      },
      [],
    );

    return const CommonScaffold(
      body: SizedBox(),
    );
  }
}
